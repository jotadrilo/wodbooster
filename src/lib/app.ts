import type {Result, Config, LambdaResult} from "./types"

const fs = require('fs')
const WodBooster = require('./wodbooster')
const Utils = require('./utils')
const yaml = require('js-yaml')
const puppeteer = require('puppeteer-extra')

async function Run(): Promise<Result[]> {
    let config: Config[]
    try {
        const configFile = process.env.WB_CONFIG_FILE ? process.env.WB_CONFIG_FILE : 'config.yml'
        console.log(`Configuration file: ${configFile}`)
        config = yaml.load(fs.readFileSync(configFile, 'utf8'))
    } catch (err) {
        return [{error: err, results: [], screenshots: []}]
    }

    let result: Result[] = []
    try {

        // Launch a browser or connect to a running one
        let browser
        let close = false
        if (process.env.WB_CHROME_ENDPOINT) {
            const endpoint = await Utils.getChromeWSEndpoint(process.env.WB_CHROME_ENDPOINT)
            console.log(`Connecting to browser (${endpoint})`)
            browser = await puppeteer.connect({browserWSEndpoint: endpoint})
        } else {
            close = true
            const path = process.env.WB_CHROME_PATH ? process.env.WB_CHROME_PATH : puppeteer.executablePath()
            console.log(`Using executable path (${path})`)
            const headless = process.env.WB_NO_HEADLESS === '1' ? false : 'new'
            const opts = {
                args: [
                    '--no-sandbox',
                    '--disable-setuid-sandbox',
                    '--disable-dev-shm-usage',
                    '--disable-accelerated-2d-canvas',
                    '--no-first-run',
                    '--no-zygote',
                ],
                headless: headless,
                ignoreHTTPSErrors: true,
                executablePath: path,
            }

            console.log(`Launching browser (${JSON.stringify(opts)})`)

            browser = await puppeteer.launch(opts)
        }

        if (process.env.WB_CHECK_HEADERS === '1') {
            console.log('Checking headers...')

            browser.newPage().then(async (page) => {
                await page.goto('https://httpbin.org/headers')
                console.log(await page.content())
                await page.close()
            })
        }

        console.log(`Launching Enroll...`)

        result = await WodBooster.Enroll(browser, config)

        if (close) {
            await browser.close()
        }
    } catch (err) {
        return [{error: err, results: [], screenshots: []}]
    }

    return result
}

async function RunLambda(): Promise<LambdaResult> {
    try {
        let result: Result[] = await Run()
        return {
            status: 200,
            body: {
                result: result,
            },
        }
    } catch (err) {
        return {
            status: 502,
            body: {
                error: err,
            },
        }
    }
}

module.exports.Run = Run
module.exports.RunLambda = RunLambda
