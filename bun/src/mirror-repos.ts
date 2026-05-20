#!/bin/env bun

import { $, file, write } from "bun"
import { mkdir, stat, exists } from "node:fs/promises"

console.info("Begin mirror-repos")

// explicit ENV binding to avoid debugging nightmare (if env file is not read for instance)
const mirrorPath = import.meta.env.MIRROR_PATH ?? ''
if (mirrorPath.length < 1) {
    console.error('Missing MIRROR_PATH')
    process.exit(1)
}

const ghUser = import.meta.env.GH_USER ?? ''
if (ghUser.length < 1) {
    console.error('Missing GH_USER')
    process.exit(1)
}

type GithubRepository = {
    name: string
    description: string
    visibility: "PRIVATE" | "PUBLIC" | "INTERNAL"
}
type MirrorKind = "mirror-a" | "mirror-b"

async function main() {
    try {
        // Fetch list of repository
        // needs gh auth to be configured
        const jsonFields = 'name,description,visibility'
        const out: GithubRepository[] = await $`gh repo list ${ghUser} --json "${jsonFields}"`.json()

        // Create needed directories
        await ensureDirectories()
        const mirrorKind: MirrorKind = await whichMirrorKind()
        await startMirrorInfo(mirrorKind)

        for (const repo of out) {
            await handleRepo(repo, mirrorKind)
        }
        await endMirrorInfo(mirrorKind)

    } catch (err) {
        if (err instanceof $.ShellError) {
            console.log(`Failed with code ${err.exitCode}`)
            console.log(err.stdout.toString())
            console.log(err.stderr.toString())
        } else {
            console.error(err)
        }
    }
}

async function ensureDirectories() {
    console.info('MIRROR_PATH is "%s"', mirrorPath)
    if (!(await stat(mirrorPath)).isDirectory()) {
        throw new Error(`MIRROR_PATH (${mirrorPath}) is not a directory`)
    }

    for (const mirrorKind of ['mirror-a', 'mirror-b'] as MirrorKind[]) {
        for (const visibility of ['PUBLIC', 'PRIVATE', 'INTERNAL'] as GithubRepository['visibility'][]) {
            const lowerVisibility = visibility.toLocaleLowerCase()
            const path = `${mirrorPath}/${mirrorKind}/${lowerVisibility}/`
            console.info('📂 mkdir "%s"', path)
            await mkdir(path, { recursive: true })
        }
    }
}

async function whichMirrorKind(): Promise<MirrorKind> {
    const mirrorFilePath = `${mirrorPath}/.current`
    let kind: MirrorKind
    const mirrorFile = file(mirrorFilePath)
    if (await mirrorFile.exists()) {
        const current = await mirrorFile.text()
        switch (current) {
            case 'mirror-a':
                // switch
                kind = 'mirror-b'
                break    
            case 'mirror-b':
                // switch
                kind = 'mirror-a'
                break;
            default:
                throw new Error(`Unexpected .current file content: ${current}`)
        }
    } else {
        // Does not exist: start at "A" and create file
        kind = 'mirror-a'
    }
    // create or overwrite
    await write(mirrorFile, kind)

    // return
    console.info('🪞 Will use mirror "%s"', kind)
    return kind
}

async function startMirrorInfo(kind: MirrorKind) {
    // update file descriptor
    const fileName = `${mirrorPath}/${kind}/mirror.info`
    await $`echo "name=${kind}" > ${fileName}`
    await $`echo "last_sync_start=${new Date()}" >> ${fileName}`
    return kind
}
async function endMirrorInfo(kind: MirrorKind) {
    const fileName = `${mirrorPath}/${kind}/mirror.info`
    await $`echo "last_sync_end  =${new Date()}" >> ${fileName}`
}

async function handleRepo(repository: GithubRepository, mirrorKind: MirrorKind) {
    console.info('🗂️ Start handling repo "%s"', repository.name)
    try {
        // if (repository.name !== 'home' && repository.name !== 'pi-cron') return // DEBUG line
        // if (repository.name === 'pi-cron') throw new Error('DEBUG EROR !!!!!')

        await _doHandleRepo(repository, mirrorKind)
    } catch (err) {
        if (err instanceof $.ShellError) {
            console.log(`Failed with code ${err.exitCode}`)
            console.log(err.stdout.toString())
            console.log(err.stderr.toString())
        } else {
            console.info('⚠️ An error occured when handling repo "%s"', repository.name)
            console.error(err)
        }
    } finally {
        console.info('✅ End handling repo "%s"', repository.name)
    }
}

async function _doHandleRepo(repository: GithubRepository, mirrorKind: MirrorKind) {
    const parentPath = `${mirrorPath}/${mirrorKind}/${repository.visibility.toLocaleLowerCase()}`
    const repoPath = `${parentPath}/${repository.name}`
    if (await exists(repoPath)) {
        console.info('📥 #syncRepo() "%s"', repository.name)
        await syncRepo(repoPath)
    } else {
        console.info('📝 #cloneRepo() "%s"', repository.name)
        await cloneRepo(repository, parentPath)
    }
}

async function cloneRepo(repository: GithubRepository, parentPath: string) {
    const shellPromise = $`gh repo clone ${ghUser}/${repository.name} -- --no-checkout --verbose`
        .cwd(parentPath)
    await shellPromise
}

async function syncRepo(repoPath: string) {
    const shellPromise = $`git fetch --tags --prune --prune-tags --verbose`
        .cwd(repoPath)
    await shellPromise
}

await main()
console.info("End mirror-repos")
