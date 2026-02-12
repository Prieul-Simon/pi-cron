#!/bin/env bun

import { file, pathToFileURL, sql, SQL } from "bun";

console.info("Begin healthcheck")

const caLocation = '/../../config/pg_ca.pem'
const ca = await file(pathToFileURL(import.meta.dir + caLocation)).text()

// explicit url binding to avoid debugging nightmare (if env file is not read for instance)
const url = import.meta.env.DATABASE_URL
if (!url || url.length < 1) {
    console.error('Missing DATABASE_URL')
    process.exit(1)
}

const pg = new SQL({
    url,
    tls: {
        rejectUnauthorized: true,
        ca,
    },
    max: 1,
    onconnect(err) {
        console.info('onconnect: %o', err ?? 'success')
    },
    onclose(err) {
        console.info('onclose: %o', err ?? '<no err>')
    },
})

const version = (await pg<{ version: string }[]>`select version()`).at(0)?.version
console.info('version: %o', version)

const testRows = await pg<{ name: boolean }[]>`
SELECT * FROM test 
LIMIT 1
`
const testResult: boolean = testRows.at(0)?.name ?? false
console.info('test result: %o', testResult)

type Attempt = {
    id?: string // by default, pg will generated random for me
    created_at: Date
    success: boolean
}
const newAttempts: Attempt[] = [
    {
        created_at: new Date(),
        success: testResult,
    }
]
const result = await pg`
INSERT INTO attempts ${sql(newAttempts)}
`
console.info('attempt insert result: %o', result)

console.info("End healthcheck")
