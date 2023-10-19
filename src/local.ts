const App = require('./lib/app')
import type {Result} from "./lib/types"

(async () => {
    try {
        let result: Result[] = await App.Run()
        console.log(`Process finished: ${JSON.stringify(result, null, 4)}`);
    } catch (err) {
        console.log(`Process threw an error: ${err}`);

    }
})()
