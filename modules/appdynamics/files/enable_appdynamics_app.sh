#!/bin/bash
#
# Enables the AppDynamics appserver agent.
# This works by modifying the setenv.sh file that Tomcat executes to set env vars
# before running.  Specifically, it specifies a number of options passed when running
# java as part of launching Tomcat.
#
# Usage: sudo ./enable_appdynamics_app.sh \
# --controllerHostName=choicetest.saas.appdynamics.com \
# --controllerPort=443 \
# --applicationName=ChoiceEdge \
# --accountName=choicetest \
# --accountAccessKey=153bcb0f2fee \
# --tierName=inventoryItemLT
#

# Declare how this script should be used
USAGE="enable_appdynamics_app.sh \
\n--controllerHostName=choicetest.saas.appdynamics.com \
\n--controllerPort=443 \
\n--applicationName=ChoiceEdge \
\n--accountName=choicetest \
\n--accountAccessKey=153bcb0f2fee \
\n--tierName=inventoryItemLT \
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
      --tierName=*)
      tierName="${i#*=}"
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
     "$accountAccessKey" == "" -o \
     "$tierName" == "" \
      ]; then
  printf "ERROR: Missing required arguments.\n"
  printf "Usage: $USAGE"
  exit 1
fi

# The AppDynamics plugin is run by adding additional args to the Java invocation for Tomcat
JAVA_OPTS_ENVVAR="JAVA_OPTS=\"\$JAVA_OPTS -javaagent:/opt/appdyn/appserveragent/javaagent.jar -Dappdynamics.agent.accountAccessKey=${accountAccessKey} -Dappdynamics.agent.accountName=${accountName} -Dappdynamics.agent.applicationName=${applicationName} -Dappdynamics.agent.nodeName=\$HOSTNAME -Dappdynamics.agent.tierName=${tierName} -Dappdynamics.controller.hostName=${controllerHostName} -Dappdynamics.controller.port=${controllerPort} -Dappdynamics.controller.ssl.enabled=True\""

# Append JAVA_OPTS to Tomcat's bin/setenv.sh file to ensure that these opts get added to the tomcat run
# Only append if it doesn't exist already
if ! grep -qe "^${JAVA_OPTS_ENVVAR}$" "/usr/share/tomcat/bin/setenv.sh"; then
  printf "\n# Enable AppDynamics AppServer Agent\n" >> /usr/share/tomcat/bin/setenv.sh
  printf "${JAVA_OPTS_ENVVAR}" >> /usr/share/tomcat/bin/setenv.sh
  printf "SUCCESS! The file '/usr/share/tomcat/bin/setenv.sh' has been updated and AppDynamics has been enabled.\n"
else
  printf "WARNING: AppDynamics App Agent already enabled.  No changes have been made.\n"
fi
