#!/bin/bash
run () {
    local FILE_NAME='test-alpine.bash'
    echo "BEGIN $FILE_NAME"

    local CONTAINER_NAME="$(/usr/bin/docker ps --format '{{.Names}}' | grep -E 'sys-alpine' | head -1)"

    # Do call the Alpine container
    /usr/bin/docker compose exec -it $CONTAINER_NAME /bin/sh -c '. /etc/os-release && echo "Container OS name is: $PRETTY_NAME"'

    echo "END $FILE_NAME"
}
run
