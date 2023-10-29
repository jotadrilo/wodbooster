const moment = require('moment')
const Utils = require('./utils')
const AWS = require('aws-sdk')
const S3 = new AWS.S3({signatureVersion: 'v4'})

import type {Config, Result, PendingDay, Workout, EnrollResult} from "./types"

class Enroller {
    private config: Config
    private result: Result

    constructor(config) {
        this.config = config
        this.result = {
            error: '',
            results: [],
            screenshots: [],
        }
    }

    getPendingDays(): PendingDay[] {
        const weekdays = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']

        let offset = this.config.offset
        const forceEnrollDay = this.config.forceEnrollDay
        const today = moment().day()

        console.log(`Today is ${weekdays[today]} (${today})`)

        if (offset === undefined) {
            offset = 0
        }

        let shift = 0
        if (forceEnrollDay !== undefined) {
            const index = weekdays.findIndex((d) => d  == forceEnrollDay)
            if (index <= offset) {
                shift = -today
            } else {
                shift = index - today - offset -1
            }
            console.log(`Simulating that today is ${weekdays[today+shift]} (${today+shift})`)
        }

        if (today + shift + offset > 6) {
            return []
        }

        let quantity: number = today + shift === 0 ? offset : 1
        let pds: PendingDay[] = []

        while (quantity-- > 0) {
            const m = moment().add(offset + shift - quantity, 'days')
            const d = m.format('dddd').toLowerCase()
            const ts = m.unix()
            pds.push({day: d, ts: ts})
            console.log(`It will process ${d} (${ts})`)
        }

        console.log(`- ${this.config.name} # Pending days: ${pds.length}`)

        return pds
    }

     async uploadScreenshot(page) {
        if (process.env.WB_NO_SCREENSHOTS === '1') {
            return {}
        }

        if (process.env.WB_LOCAL_SCREENSHOTS === '1') {
            const basePath = process.env.WB_LOCAL_SCREENSHOTS_BASE_PATH ? process.env.WB_LOCAL_SCREENSHOTS_BASE_PATH : '/tmp'
            const path = basePath + '/' + moment().format('x') + '.png'
            await page.screenshot({type: 'png', path: path})
            return {path: path}
        }

        const params = {
            Body: await page.screenshot({type: 'png'}),
            Bucket: process.env.WB_BUCKET_NAME,
            ContentType: 'image/png',
            CacheControl: 'max-age=31536000',
            Key: moment().format('x') + '.png',
            StorageClass: 'STANDARD'
        }

        const res = await S3.putObject(params).promise().then((data) => {
            return {url: `https://${params.Bucket}.s3.amazonaws.com/${params.Key}`, data: data}
        }).catch((error) => {
            console.error(error)
            return {error: error}
        })

        this.result.screenshots.push(res)
    }

    async access(page) {
        const name = this.config.name

        console.log(`- ${name} # - Accessing web page`)

        try {
            await page.goto('https://momafit.wodbuster.com/user', {waitUntil: 'load'})
            await this.uploadScreenshot(page)
        } catch(error) {
            console.log(error)
        }

        console.log(`- ${name} # - Waiting for main menu`)

        // Skip login if we are in the main menu (for example, if we are using an existing browser
        // that cached our session
        let inMainMenu = false
        try {
            await page.waitForSelector('.mainmenu', {timeout: 500})
            inMainMenu = true
        } catch(error) {
            console.log(error)
        }

        if (!inMainMenu) {
            // await page.goto('https://momafit.wodbuster.com/account/login.aspx')

            const loginButtonSelector = '#body_body_body_body_CtlEntrar'
            console.log(`- ${name} # - Waiting for login button (${loginButtonSelector})`)

            await page.waitForSelector(loginButtonSelector, {timeout: 2000})

            let user = Utils.normEnvTemplate(this.config.username)
            let pass = Utils.normEnvTemplate(this.config.password)

            console.log(`- ${name} # - Trying to type credentials "${user}:******"`)

            await page.type('#body_body_body_body_IoEmail', user)
            await page.type('#body_body_body_body_IoPassword', pass)

            await this.uploadScreenshot(page)

            console.log(`- ${name} # - Trying to click button`)

            await page.click(loginButtonSelector)

            await this.uploadScreenshot(page)
        }
    }

    async enrollWorkout(page, w: Workout): Promise<boolean> {
        const name = this.config.name
        const selector = `//div[contains(@class, "rowClase") and ./div[@class="entrenamientoHead" and ./div[@class="entrenamiento" and contains(text(), "${w.name}")] and ./div[@class="hora" and contains(text(), "${w.hour}")]]]//button[contains(., "Entrenar")]`

        console.log(`- ${name} # - Trying to click "${w.name}" at "${w.hour}" button (${selector})...`)

        const [button] = await page.$x(selector)

        if (button === undefined) {
            console.log(`- ${name} # - Unable to click button`)
            return false
        }

        await button.focus()

        await this.uploadScreenshot(page)

        await button.click()

        console.log(`- ${name} # - Enrolled button`)

        return true
    }

    async enrollPendingDay(page, pd: PendingDay) {
        const result: EnrollResult = {
            name: this.config.name,
            errors: [],
            enrolled: [],
        }

        const workouts = this.config.workouts[pd.day]

        console.log(`- ${this.config.name} # Processing day "${pd.day}" (${pd.ts})...`)

        await page.goto('https://momafit.wodbuster.com/athlete/reservas.aspx?t=' + pd.ts, {waitUntil: 'load'})

        await this.uploadScreenshot(page)

        // Reload until we find the expected class
        try {
            await Utils.reloadForSelector(page, '.rowHora', 15 * 60 * 1000)
        } catch(err) {
            console.log(err)
            result.errors = [`Unable to process day "${pd.day}" (${pd.ts}): ${err}`]
            this.result.results.push(result)
            return
        }

        for (let w of workouts) {
            try {
                const enrolled = await this.enrollWorkout(page, w)
                if (enrolled) {
                    result.enrolled.push({workout: w, day: pd})
                    await Utils.sleep(750)
                }
            } catch(err) {
                console.log(err)
                result.errors.push(`Unable to click "${w.name}" at "${w.hour}" button: ${err}`)
            }
        }

        this.result.results.push(result)
    }

    async enroll(browser) {
        const pendingDays: PendingDay[] = this.getPendingDays()
        if (pendingDays.length === 0) {
            return this.result
        }

        const page = await Utils.newPage(browser)

        await this.access(page)

        for (let item of pendingDays) {
            await this.enrollPendingDay(page, item)
        }

        await page.close()

        return this.result
    }

}

async function Enroll(browser, config) {
    const results: Result[] = []

    for (let c of config) {
        console.log(`Enrolling workouts for "${c.name}"...`)
        const e = new Enroller(c)
        try {
            results.push(await e.enroll(browser))
        } catch(error) {
            console.log(error)
        }
    }

    return results
}

module.exports.Enroll = Enroll
