#!/bin/bash
run () {
    local FILE_NAME='renew-cert.bash'
    echo "BEGIN $FILE_NAME"

    # Test
    if [[ -z "$CURRENT_USER_LOC" ]]; then
        echo "CURRENT_USER_LOC is empty, cannot renew cert"
        exit 1
    fi

    local CONTAINER_NAME="$(/usr/bin/docker ps --format '{{.Names}}' | grep -E 'certbot-prieulfr' | head -1)"

    # Execute sh file from bound volume
    /usr/bin/docker exec -i $CONTAINER_NAME /bin/sh -c 'cd /certbot-work && ./call_certbot.sh'

    # tmp debug code
    local LAST_RETURN_CODE=$?
    echo "last return code is: $LAST_RETURN_CODE"

    # copy files to the expected location and update symbolic links
    local DATE_SUFFIX="$(date +%Y)-$(date +%m)"
    local VOLUME_OUTPUT_DIR="$CURRENT_USER_LOC/storage/microsd/data/certbot-prieulfr/etc-letsencrypt/live/prieul.fr"
    local NGINX_DIR="$CURRENT_USER_LOC/cert/prieul.fr"
    cp "$VOLUME_OUTPUT_DIR/fullchain.pem" "$NGINX_DIR/fullchain-$DATE_SUFFIX.pem"
    cp "$VOLUME_OUTPUT_DIR/privkey.pem" "$NGINX_DIR/privkey-$DATE_SUFFIX.pem"
    ln -sf "fullchain-$DATE_SUFFIX.pem" "$NGINX_DIR/fullchain-fixme.pem"
    ln -sf "privkey-$DATE_SUFFIX.pem" "$NGINX_DIR/privkey-fixme.pem"

    echo "END $FILE_NAME"
}
run
