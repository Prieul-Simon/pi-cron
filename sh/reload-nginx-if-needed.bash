#!/bin/bash
run () {
    local FILE_NAME='reload-nginx-if-needed.bash'
    echo "BEGIN $FILE_NAME"

    # check .nginx_need_reload file is here
    local CURRENT_USER=$(whoami)
    echo "current user is: $CURRENT_USER"
    local NGINX_DIR="/home/$CURRENT_USER/cert/prieul.fr"
    local RELOAD_FILE="$NGINX_DIR/.need_nginx_reload"
    if [ ! -f "$RELOAD_FILE" ]; then
        echo "$RELOAD_FILE does not exist. No need to reload nginx"
        echo "END $FILE_NAME"
        exit 0
    fi

    local NGINX_CONTAINER="$(/usr/bin/docker ps --format "{{.Names}}" | grep -E "nginx-pi" | head -1)"

    # Send "nginx reload" command without stopping container
    if [ -n "$NGINX_CONTAINER" ]; then
        echo "Found nginx container: $NGINX_CONTAINER"
        echo "Attempting graceful nginx reload..."

        if /usr/bin/docker exec "$NGINX_CONTAINER" nginx -s reload 2>/dev/null; then
            echo "✅ Nginx reloaded successfully"
        else
            echo "⚠️  Nginx reload failed"
            echo "END $FILE_NAME"
            exit 1
        fi
    else
        echo "⚠️  Nginx container not found"
        echo "END $FILE_NAME"
        exit 1
    fi

    # remove the file at the end
    rm --verbose $RELOAD_FILE

    # "Normal" ending
    echo "END $FILE_NAME"
    exit 0
}
run
