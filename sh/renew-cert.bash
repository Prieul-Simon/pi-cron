#!/bin/bash
run () {
    local FILE_NAME='renew-cert.bash'
    echo "BEGIN $FILE_NAME"

    local CONTAINER_NAME="$(/usr/bin/docker ps --format '{{.Names}}' | grep -E 'certbot-prieulfr' | head -1)"

    # Execute sh file from bound volume
    /usr/bin/docker exec -i $CONTAINER_NAME /bin/sh -c 'cd /certbot-work && ./call_certbot.sh'

    echo "END $FILE_NAME"
}
run
