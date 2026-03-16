#!/bin/sh

# At 05:30 everyday
CRON_CONFIG='30 5 * * *'

# Need current user
CURRENT_USER_LOC=$HOME
CRONTAB_ENV_SETTER="export CURRENT_USER_LOC=$CURRENT_USER_LOC"

SCRIPT_ABS_PATH=$(realpath ./reload-nginx-if-needed.bash)
LOGGER_TAG='cron_reload_nginx'

# Whole line that will be appended to crontab
CRON_JOB="$CRON_CONFIG $CRONTAB_ENV_SETTER; $SCRIPT_ABS_PATH 2>&1 | logger --tag $LOGGER_TAG"

# Do the appending
crontab -l | { cat; echo "$CRON_JOB"; } | crontab -
