#!/bin/sh


# Every 5 minute, and pipe output to cron service output
CRON_CONFIG='*/5 * * * *'
# Certbot only renews certificates within 30 days of expiration, so running it daily is safe
# At 04:58 everyday
# CRON_CONFIG='58 4 * * *'

# Need current user
CURRENT_USER_LOC=$HOME
CRONTAB_ENV_SETTER="export CURRENT_USER_LOC=$CURRENT_USER_LOC"

SCRIPT_ABS_PATH=$(realpath ./renew-cert.bash)
LOGGER_TAG='cron_renew_cert'

# Whole line that will be appended to crontab
CRON_JOB="$CRON_CONFIG $CRONTAB_ENV_SETTER; $SCRIPT_ABS_PATH 2>&1 | logger --tag $LOGGER_TAG"

# Do the appending
crontab -l | { cat; echo "$CRON_JOB"; } | crontab -
