#!/bin/sh

# Certbot only renews certificates within 30 days of expiration, so running it daily is safe

# Every 5 minute, and pipe output to cron service output
CRON_CONFIG='*/5 * * * *'
# At 04:58 on day(s) 15th in March, June, September, December
# CRON_CONFIG='58 4 15 3,6,9,12 *'

SCRIPT_ABS_PATH=$(realpath ./renew-cert.bash)
LOGGER_TAG='cron_renew_cert'

# Whole line that will be appended to crontab
CRON_JOB="$CRON_CONFIG $SCRIPT_ABS_PATH 2>&1 | logger --tag $LOGGER_TAG"

# Do the appending
crontab -l | { cat; echo "$CRON_JOB"; } | crontab -
