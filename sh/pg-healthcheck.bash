#!/bin/bash
run () {
    local FILE_NAME='pg-healthcheck.bash'
    echo "BEGIN $FILE_NAME"

    local RELATIVE_PATH_BUN_SCRIPT='../bun/src/pg-healthcheck.ts'
    local ABSOLUTE_PATH_BUN_SCRIPT="${BASH_SOURCE%/*}/$RELATIVE_PATH_BUN_SCRIPT"
    local RESOLVED_ABSOLUTE_PATH_BUN_SCRIPT=$(realpath $ABSOLUTE_PATH_BUN_SCRIPT)

    local RELATIVE_PATH_ENVFILE='../bun/.env.production'
    # local RELATIVE_PATH_ENVFILE='../bun/.env.development.local'
    local ABSOLUTE_PATH_ENVFILE="${BASH_SOURCE%/*}/$RELATIVE_PATH_ENVFILE"
    local RESOLVED_ABSOLUTE_PATH_ENVFILE=$(realpath $ABSOLUTE_PATH_ENVFILE)

    # Delegate to Bun script
    bun --env-file=$RESOLVED_ABSOLUTE_PATH_ENVFILE run $RESOLVED_ABSOLUTE_PATH_BUN_SCRIPT

    echo "END $FILE_NAME"
}
run
