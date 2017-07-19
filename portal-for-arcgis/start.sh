#!/bin/bash
#
#  Run this in an ArcGIS container to start the Portal server
#  and configure it with the default admin/password and site
#
HOSTNAME=`hostname`

# ESRI likes its hostname to be ALL UPPER CASE! but SOMETIMES not
UPPERHOST=`python3 UPPER.py "$HOSTNAME"`

# Our hostname is different than when we built this container image,
# fix up the name of our properties file
ln -s .ESRI.properties.*.${ESRI_VERSION} .ESRI.properties.${HOSTNAME}.${ESRI_VERSION}

# Clean out the content folder so we don't go into "upgrade" mode.
echo "Clearing out previous data"
cd portal/usr/arcgisportal/ && \
  rm -rf content/* db dsdata index pgsql* sql logs/${UPPERHOST}/portal/*.l*

# This would probably be a good place to put code to authorize a
# license file if you have not done that already
# Check status first
#./server/tools/authorizeSoftware -s

# Is it running already? 
echo "Starting Portal ArcGIS"
cd ${HOME}
./portal/startportal.sh

# Pause for server to start
sleep 6

# Find the log file. The hostname has to be UPPERCASE, gag me.
# will get in trouble here if there are many log files, need entire datestamp thing
# but we deleted all the logs up above, yikes, what a hack
export LOGFILE="${HOME}/portal/usr/arcgisportal/logs/${UPPERHOST}/portal/*.log"
echo "Logfile is $LOGFILE"

echo "Waiting for Portal server to start..."
curl --retry 15 -sS --insecure "https://${HOSTNAME}:7443/arcgis/home" > /tmp/apphttp
if [ $? != 0 ]; then
    echo "ArcGIS did not start. $?"
    exit 1
fi

echo "Configuring initial site." 
python3 create_new_site.py

exit 0
