#!/bin/bash
#
#  Run this in an ArcGIS container to install and start the server
#  and configure it with the default admin/password and site
#
# Required ENV settings:
# HOSTNAME HOME ESRI_VERSION

echo My hostname is $HOSTNAME 

if [ "$AGS_USERNAME" = "" -o "$AGS_PASSWORD" = "" ]
then
    echo "You must define AGS_USERNAME and AGS_PASSWORD in the environment."
    exit 1
fi

source /app/bashrc
cd /home/arcgis

PROPERTIES=".ESRI.properties.${HOSTNAME}.${ESRI_VERSION}"

UNINSTALLER="/home/arcgis/server/uninstall_ArcGISServer"
# Has the server been installed yet?
SCRIPT="/home/arcgis/server/framework/etc/scripts/agsserver.sh"
if [ -f $SCRIPT ]; then
  echo "ArcGIS Server is already installed."
  #$SCRIPT status
  #rm -rf server .ESRI.properties* .com.zerog.registry.xml
  #authorizeSoftware -s
else
  echo "Installing ArcGIS Server."
  cd /app/ArcGISServer && ./Setup --verbose -l yes -m silent
  authorizeSoftware -f /app/authorization.prvc
fi

serverinfo

# Clumsily wipe all log files so when we start
# there will only be one.
# TODO find the current logfile instead
# amd remove only old logs
LOGDIR=/home/arcgis/server/usr/logs/SERVER.LOCAL/server/
rm -rf $LOGDIR/*.log $LOGDIR/*.lck

echo ""
echo "Retarting ArcGIS Server"
$SCRIPT restart

# Pause for server to start
echo -n "Waiting for ArcGIS Server to start..."
sleep 15
curl --retry 6 -sS --insecure "https://$HOSTNAME:6443/arcgis/manager" > /tmp/apphttp
if [ $? != 0 ]; then
  echo "Server did not start. $?"
else
  echo "okay!"
fi

# I can start a process here that finds the current log file
# and tails it to STDOUT
# I don't have a way to start in "no daemon" mode
# so I need something to run here...
# Note there are many logs, this is the one for "server"
tail -f $LOGDIR/*log