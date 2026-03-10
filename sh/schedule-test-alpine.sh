#!/bin/sh

# Every minute, and pipe output to cron service output
CRON_CONFIG='* * * * *'

SCRIPT_ABS_PATH=$(realpath ./test-alpine.bash)
LOGGER_TAG='cron_test_alpine'

# Whole line that will be appended to crontab
CRON_JOB="$CRON_CONFIG $SCRIPT_ABS_PATH 2>&1 | logger --tag $LOGGER_TAG"

# Do the appending
crontab -l | { cat; echo "$CRON_JOB"; } | crontab -
