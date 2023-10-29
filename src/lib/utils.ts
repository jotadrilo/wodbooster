const nfetch = require('node-fetch');

function normEnvTemplate(tpl: String) {
    tpl = tpl.replaceAll('{', '')
    tpl = tpl.replaceAll('}', '')
    // @ts-ignore
    return process.env[tpl]
}


async function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
}

async function reloadForSelector(page, selector, timeout) {
    const sleepDuration = 500

    if (timeout < sleepDuration) {
        timeout = sleepDuration
    }

    const max = Math.floor(timeout / sleepDuration)
    let count = 0
    let found = false

    while (!found && count < max) {
        count++
        try {
            console.log(`Looking for "${selector}" selector (attempt: ${count}/${max})`)
            await page.waitForSelector(selector, {timeout: 500})
            found = true
        } catch (err) {
            console.log(err)

            try {
                await page.reload({waitUntil: 'load', timeout: 500})
            } catch (err) {
                console.error(err)
            }

            await sleep(sleepDuration)
        }
    }

    if (!found) {
        const err = new Error(`selector not found in ${timeout} ms: ${selector}`)
        err.name = 'Timeout'
        throw err
    }
}

async function newPage(browser) {
    try {
        const page = await browser.newPage()
        // await page.setUserAgent('Mozilla/5.0 (X11 Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36')
        // await page.setViewport({width: 1080, height: 1024})
        return page
    } catch (error) {
        console.log(error)
    }

    return undefined
}

async function getChromeWSEndpoint(url: string) {
    let endpoint

    const u = `http://${url}/json/version`
    console.log(`Querying Chrome endpoint: ${u}`)

    try {
        await nfetch(u)
            .then(response => response.text())
            .then(text => endpoint = JSON.parse(text).webSocketDebuggerUrl)
    } catch (err) {
        console.log(err)
    }

    return endpoint
}

module.exports = {
    getChromeWSEndpoint: getChromeWSEndpoint,
    newPage: newPage,
    normEnvTemplate: normEnvTemplate,
    reloadForSelector: reloadForSelector,
    sleep: sleep,
}
