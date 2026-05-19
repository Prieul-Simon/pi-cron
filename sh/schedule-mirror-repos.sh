#!/bin/sh

# At 11:15 AM on Sunday, and pipe output to cron service output
# CRON_CONFIG='15 11 * * 0'
# At 06:45 everyday
CRON_CONFIG='45 6 * * *'

# Need bun
BUN_BINARY_LOC=$BUN_INSTALL/bin
CRONTAB_PATH_SETTER="PATH=$BUN_BINARY_LOC:/usr/bin"

SCRIPT_ABS_PATH=$(realpath ./mirror-repos.bash)
LOGGER_TAG='cron_mirror_repos'

# Whole line that will be appended to crontab
CRON_JOB="$CRON_CONFIG $CRONTAB_PATH_SETTER; $SCRIPT_ABS_PATH 2>&1 | logger --tag $LOGGER_TAG"

# Do the appending
crontab -l | { cat; echo "$CRON_JOB"; } | crontab -
