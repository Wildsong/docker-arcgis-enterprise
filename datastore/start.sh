#!/bin/bash
#
# Start the Datastore component
#
# Required ENV settings:
# HOSTNAME ESRI_VERSION
# AGE_SERVER AGE_USERNAME AGE_PASSWORD

if [ "$AGE_USERNAME" = "" -o "$AGE_PASSWORD" = "" -o "$AGE_SERVER" = "" ]
then
    echo "Make sure AGE_USERNAME, AGE_PASSWORD, AGE_SERVER"
    echo "are defined in the environment and try again."
    exit 1
fi

source /app/bashrc
cp /app/bashrc /home/arcgis/.bashrc

if [ "$DS_DATADIR" == "" ]; then 
  # Run the ESRI installer script as user 'arcgis' with these options:
  #   -m silent         silent mode: don't pop up windows, we don't have a screen
  #   -l yes            Agree to the License Agreement
  cd /app/ArcGISDataStore && ./Setup -m silent --verbose -l yes -d /home
fi

echo My hostname is $HOSTNAME

# Clumsily wipe all log files so when we start there will only be one.
# TODO find the current logfile instead amd remove only old logs
rm  -rf $LOGDIR/DATASTORE.LOCAL/server/*.l??

SCRIPT=/home/arcgis/datastore/framework/etc/scripts/arcgisdatastore.sh
if [ -f ${SCRIPT} ]; then
  echo "Restarting DataStore"
  ${SCRIPT} restart
fi

DATASTORE_URL="https://${AGE_DATASTORE}:2443/arcgis/"
echo -n "Waiting for Datastore to start.. "
sleep 10
# --head = only header
# --retry 10 = try 10 times with exponential backoff
# -sS = be silent but show an error if there is one
curl --retry 6 -sS --insecure --head $DATASTORE_URL > /tmp/dshttp
if [ $? != 0 ]; then
  echo "DataStore not responding. $?"
else
  echo "okay!"
fi

# Put things in more sensible locations for persistence
#
#LOGDIR=/home/arcgis/log
LOGDIR=/home/arcgis/datastore/usr/arcgisdatastore/logs
changeloglocation.sh ${LOGDIR}
#
#changenosqldslocation.sh ${TILECACHE_DIR}
#changebackuplocation.sh ${BACKUP_DIR}

SERVER_URL="https://${AGE_SERVER}:6443/arcgis/"
echo -n "Waiting for Server ${AGE_SERVER}.. "
curl --retry 7 -sS --insecure --head $SERVER_URL > /tmp/dshttp
if [ $? != 0 ]; then
  echo "Server did not respond: $?"
else
  echo "okay!"
fi

# Re-running configuredatastore.sh does not appear to damage anything.
# The "relational" option means it will use its internal postgresql instance.
echo "Configuring datastore. Data will end up here: $DS_DATADIR"
configuredatastore.sh https://${AGE_SERVER}:6443 ${AGE_USERNAME} ${AGE_PASSWORD} ${DS_DATADIR} --stores relational
describedatastore.sh

echo "Try reaching me at ${DATASTORE_URL}"

# I can start a process here that finds the current log file
# and tails it to STDOUT
# I don't have a way to start in "no daemon" mode
# so I need something to run here...
# DataStore logs are boring, by the way.
# Note there are many logs, this is the one for "server"
#
tail -f $LOGDIR/DATASTORE.LOCAL/server/*.log
