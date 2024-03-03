#!/bin/bash
#
# Start the Datastore component
#
# Required ENV settings:
# HOSTNAME HOME ESRI_VERSION
# AGE_SERVER AGE_USERNAME AGE_PASSWORD

if [ "$AGE_USERNAME" = "" -o "$AGE_PASSWORD" = "" -o "$AGE_SERVER" = "" ]
then
    echo "Make sure AGE_USERNAME, AGE_PASSWORD, AGE_SERVER"
    echo "are defined in the environment and try again."
    exit 1
fi

source /app/bashrc

if [ "$DS_DATADIR" == "" ]; then 
  # Run the ESRI installer script as user 'arcgis' with these options:
  #   -m silent         silent mode: don't pop up windows, we don't have a screen
  #   -l yes            Agree to the License Agreement
  cd /app/ArcGISDataStore && ./Setup -m silent --verbose -l yes -d /home
fi

echo My hostname is $HOSTNAME


SCRIPT=/home/arcgis/datastore/framework/etc/scripts/arcgisdatastore.sh
if [ -f ${SCRIPT} ]; then
  echo "Restarting DataStore"
  $SCRIPT restart
fi

# Clumsily wipe all log files so when we start
# there will only be one.
# TODO find the current logfile instead
# amd remove only old logs
LOGDIR=/home/arcgis/datastore/usr/arcgisdatastore/logs/DATASTORE.LOCAL/server
rm -rf $LOGDIR/*.log $LOGDIR/*.lck

echo -n "Waiting for Datastore to become ready.. "
sleep 10
# --head = only header
# --retry 10 = try 10 times with exponential backoff
# -sS = be silent but show an error if there is one
curl --retry 6 -sS --insecure --head "https://localhost:2443/arcgis/datastore/" > /tmp/dshttp
if [ $? != 0 ]; then
  echo "Datastore not responding: $?"
  exit 1
else
  echo "okay!"
fi

echo -n "Waiting for Server ${AGE_SERVER}.. "
curl --retry 7 -sS --insecure --head "https://${AGE_SERVER}:6443/arcgis/" > /tmp/dshttp
if [ $? != 0 ]; then
  echo "Server did not respond: $?"
  exit 1
else
  echo "okay!"
fi

# Re-running configuredatastore.sh does not appear to damage anything.
# This will create the various and sundry files in the VOLUME "data"
# The "relational" option means it will use its internal postgresql instance.
echo DS DataDir = ${DS_DATADIR}
configuredatastore.sh https://${AGE_SERVER}:6443 ${AGE_USERNAME} ${AGE_PASSWORD} ${DS_DATADIR} --stores relational
describedatastore.sh

# Site configuration is done by REST
# so really it can be done from any container
# but I am doing it here because we know that both
# Server and Datastore are available right now.

# Is a site configured?
#if??
  echo "Configuring site." 
  /app/create_new_site.py $AGE_SERVER $AGE_USERNAME $AGE_PASSWORD
#fi

echo "Try reaching me at https://${HOSTNAME}:2443/"

# I can start a process here that finds the current log file
# and tails it to STDOUT
# I don't have a way to start in "no daemon" mode
# so I need something to run here...
# DataStore logs are boring, by the way.
# Note there are many logs, this is the one for "server"
tail -f $LOGDIR/*log
