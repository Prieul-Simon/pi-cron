#!/bin/bash
run () {
    local FILE_NAME='renew-cert.bash'
    echo "BEGIN $FILE_NAME"

    # Test
    echo "CURRENT_USER_LOC value: $CURRENT_USER_LOC"
    if [[ -z "$CURRENT_USER_LOC" ]]; then
        echo "CURRENT_USER_LOC is empty, cannot renew cert"
        exit 1
    fi
    local CURRENT_USER=$(whoami)
    echo "current user is: $CURRENT_USER"

    local CONTAINER_NAME="$(/usr/bin/docker ps --format '{{.Names}}' | grep -E 'certbot-prieulfr' | head -1)"

    # Execute sh file from bound volume
    /usr/bin/docker exec -i $CONTAINER_NAME /bin/sh -c 'cd /certbot-work && ./install_hooks.sh && ./call_certbot.sh'

    echo "END $FILE_NAME"
}
run
