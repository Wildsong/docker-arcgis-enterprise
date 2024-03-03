#!/bin/bash
#
#  Run this in an ArcGIS container to start the Portal server
#  and configure it with the default admin/password and site
#
HOSTNAME=`hostname`

# FIXME
# Clean out the content folder so we don't go into "upgrade" mode.
# This is just a hack while I figure things out!!!

echo "Clearing out previous data"
cd portal/usr/arcgisportal/ && \
  rm -rf content/* db dsdata index pgsql* sql logs/${UPPERHOST}/portal/*.l*

echo Installing into $HOME
cd /app/PortalForArcGIS && ./Setup -m silent --verbose -l yes -d $HOME

# Is it running already? 
echo "Starting Portal ArcGIS"
cd ${HOME}
./portal/startportal.sh

# Pause for server to start
sleep 10

echo "Waiting for Portal server to start..."
curl --retry 15 -sS --insecure "https://${HOSTNAME}:7443/arcgis/home" > /tmp/apphttp
if [ $? != 0 ]; then
    echo "ArcGIS did not start. $?"
    exit 1
fi

exit 0
