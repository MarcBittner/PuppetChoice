#!/bin/bash

#
# This script gets included on each appserver box and
# is responsible for deploying the appropriate war file
# when we are bootstrapping an application instance from
# the appserver base image.
#

SOURCE_URL=$1
TARGET_NAME=$2
WEBAPPS_PATH=/usr/share/tomcat/webapps

DEPLOY_PATH=$WEBAPPS_PATH/$TARGET_NAME
TMP_PATH=/tmp/$TARGET_NAME
curl --silent $SOURCE_URL -k -o $TMP_PATH

mv $TMP_PATH $DEPLOY_PATH

# extract the war
DEPLOY_FOLDER=`echo $WAR_FILE_NAME | sed s/\.war//`
cd $WEBAPPS_PATH
unzip $WAR_FILE_NAME -d $DEPLOY_FOLDER

# re-run prep for launch
/etc/init.d/prep-for-launch