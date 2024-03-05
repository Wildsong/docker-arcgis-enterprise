#!/bin/bash
#
#  Run this in an ArcGIS container to install and start the server
#
# Required ENV settings:
# HOSTNAME ESRI_VERSION

source /app/bashrc
cp /app/bashrc /home/arcgis/.bashrc

PROPERTIES=".ESRI.properties.${HOSTNAME}.${ESRI_VERSION}"

# Clumsily wipe all log files so when we start
# there will only be one.
# TODO find the current logfile instead
# amd remove only old logs
LOGDIR=/home/arcgis/server/usr/logs/SERVER.LOCAL/server/
rm -rf $LOGDIR/*.log $LOGDIR/*.lck

# Has the server been installed yet?
SCRIPT="/home/arcgis/server/framework/etc/scripts/agsserver.sh"
if [ -f $SCRIPT ]; then
  # Starting ArcGIS Server
  $SCRIPT start
else
  echo "Installing ArcGIS Server."
  /app/Installer/Setup -m silent --verbose -l yes
fi

echo "Server info"
serverinfo

KEYCODES="/home/arcgis/server/framework/runtime/.wine/drive_c/Program\ Files/ESRI/License${ESRI_VERSION}/sysgen/keycodes"

# Has it been authorized?
if authorizeSoftware -s | grep arcsdeserver; then 
  authorizeSoftware -s | tail -6
else
  echo "Authorizing."
  authorizeSoftware -f /app/server.prvc
fi
echo ""

SERVER_URL="https://${HOSTNAME}:6443/arcgis/manager/"
echo -n "Waiting for ArcGIS Server to start..."
sleep 10
curl --retry 6 -sS --insecure $SERVER_URL > /tmp/apphttp
if [ $? != 0 ]; then
  echo "Server did not start. $?"
else
  echo "okay!"
fi

# Has this server been configured?
if true ; then
    configurebasedeployment.sh -f /app/configurebasedeployment.properties
fi

echo "Try reaching me at ${SERVER_URL}"

# I can start a process here that finds the current log file
# and tails it to STDOUT
# I don't have a way to start in "no daemon" mode
# so I need something to run here...
# Note there are many logs, this is the one for "server"
tail -f $LOGDIR/*log
