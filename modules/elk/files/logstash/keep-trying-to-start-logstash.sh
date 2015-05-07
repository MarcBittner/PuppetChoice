#!/bin/sh
#
# Logstash is automatically started on boot, but Logstash will fail to start if it can't find
# its private SSL key and won't attempt to restart itself.  One solution is to just reboot the
# instance, but since we want to automate everything, this script keeps checking Logstash to see
# if it's running.  If it is, the script dies.  If it's not, attempt to start, wait a bit, and
# then check again.
#
# Usage: ./keep-trying-to-start-logstash.sh

# - Wait 150 secs
LOGSTASH_IS_RUNNING=0

checkLogstashStatus ()
{ # Check whether logstash is running

  printf "Checking status of Logstash...\n"

  # See what the init.d script reports...
  service logstash status 1> /dev/null

  # Check the return code of the status command and set our global var accordingly
  if [ $? -eq 0 ]; then
    printf "Logstash is running.\n"
    LOGSTASH_IS_RUNNING=1
  else
    printf "Logstash is not running.\n"
    LOGSTASH_IS_RUNNING=0
  fi
}

# Check right away if Logstash is running
checkLogstashStatus

# If Logstash isn't running, keep trying to start logstash
while [ $LOGSTASH_IS_RUNNING -eq 0 ]; do
  SLEEP_SECONDS=20

  printf "[bash: service logstash start] "
  service logstash start

  printf "Sleeping $SLEEP_SECONDS seconds so Logstash has time to boot...\n"
  sleep $SLEEP_SECONDS

  checkLogstashStatus
done
