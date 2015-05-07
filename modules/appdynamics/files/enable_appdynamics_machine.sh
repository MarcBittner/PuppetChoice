#!/bin/sh
#
# AppDynamics Machine Agent Startup
# Inspired by https://docs.appdynamics.com/display/PRO39/Machine+Agent+Install+and+Admin+FAQ
#
# Writes an entry to rc.local so that agent will run in background on boot
#
# Usage: sudo ./enable_appdynamics_machine.sh \
# --controllerHostName=choicetest.saas.appdynamics.com \
# --controllerPort=443 \
# --applicationName=ChoiceEdge \
# --accountName=choicetest \
# --accountAccessKey=153bcb0f2fee
#

# Declare how this script should be used
USAGE="enable_appdynamics_app.sh \
\n--controllerHostName=choicetest.saas.appdynamics.com \
\n--controllerPort=443 \
\n--applicationName=ChoiceEdge \
\n--accountName=choicetest \
\n--accountAccessKey=153bcb0f2fee \
\n"

# Bash ugliness for converting named command-line args into env vars
# Ugliness inspired by http://stackoverflow.com/a/14203146/2308858
for i in "$@"; do
  case $i in
      --controllerHostName=*)
      controllerHostName="${i#*=}"
      shift
      ;;
      --controllerPort=*)
      controllerPort="${i#*=}"
      shift
      ;;
      --applicationName=*)
      applicationName="${i#*=}"
      shift
      ;;
      --accountName=*)
      accountName="${i#*=}"
      shift
      ;;
      --accountAccessKey=*)
      accountAccessKey="${i#*=}"
      shift
      ;;
      *)
              # unknown option
      ;;
  esac
done

# If missing any args, complain
if [ "$controllerHostName" == "" -o \
     "$controllerPort" == "" -o \
     "$applicationName" == "" -o \
     "$accountName" == "" -o \
     "$accountAccessKey" == "" \
      ]; then
  printf "ERROR: Missing required arguments.\n"
  printf "Usage: $USAGE"
  exit 1
fi


JAVA="java -Xmx32m"
AGENT_HOME="/opt/appdyn/machineagent"
AGENT="$AGENT_HOME/machineagent.jar"

# Agent Options
# Uncomment and make available as needed
# -Dappdynamics.controller.hostName     :
# -Dappdynamics.controller.port         :
# -Dappdynamics.agent.applicationName   : application that the agent participates in
# -Dappdynamics.agent.logging.dir       : directory to put logs (agent "user" must have write permissions
# -Dmetric.http.listener=true | false   : open a kill port
# -Dmetric.http.listener.port			      : the port to send kill messages

AGENT_OPTIONS=""
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.hostName=${controllerHostName}"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.controller.port=${controllerPort}"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.applicationName=${applicationName}"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.accountName=${accountName}"
AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.accountAccessKey=${accountAccessKey}"
#AGENT_OPTIONS="$AGENT_OPTIONS -Dappdynamics.agent.logging.dir="
#AGENT_OPTIONS="$AGENT_OPTIONS -Dmetric.http.listener=true | false
#AGENT_OPTIONS="$AGENT_OPTIONS -Dmetric.http.listener.port=<port>"

# Launch the agent at boot
COMMAND="su ec2-user -c \"nohup $JAVA $AGENT_OPTIONS -jar $AGENT >> $AGENT_HOME/logs/machine-agent.log 2>&1 &\""
grep -q "$COMMAND" /etc/rc.d/rc.local || (echo "$COMMAND" >> /etc/rc.d/rc.local && echo "SUCCESS! '/etc/rc.d/rc.local' has been updated to launch the AppDynamics machine agent on boot.")
