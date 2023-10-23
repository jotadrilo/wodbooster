export interface PendingDay {
    day: string
    ts: number
}

export interface ScreenshotUpload {
    url?: string
    data?: any
    error?: any
}

export interface Enrolled {
    workout: Workout
    day: PendingDay
}

export interface Result {
    error: string
    results: EnrollResult[]
    screenshots: ScreenshotUpload[]
}

export interface LambdaResult {
    status: number
    body: LambdaBody
}

export interface LambdaBody {
    result?: Result[]
    error?: string
}

export interface EnrollResult {
    name: string
    enrolled: Enrolled[]
    errors: string[]
}

export interface Config {
    name: string,
    username: string,
    password: string,
    offset?: number,
    forceEnrollDay?: string,
    workouts: Map<String, Workout[]>,
}

export interface Workout {
    name: string,
    hour: string,
}
