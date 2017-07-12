#!/bin/bash
#
#  Run this in an ArcGIS container to start the Portal server
#  and configure it with the default admin/password and site
#
HOSTNAME=`hostname`
cd ${HOME}

# This would probably be a good place to put code to authorize a
# license file if you have not done that already
# Check status first
#./server/tools/authorizeSoftware -s

# Clean out the content folder so we don't go into "upgrade" mode.
cd portal/usr/arcgisportal/
rm -rf content/* db dsdata index pgsql* sql
cd ~

echo "Starting Portal ArcGIS"
./portal/startportal.sh

# Pause for server to start
sleep 5

echo "Waiting for Portal server to start..."
curl --retry 15 -sS --insecure "https://${HOSTNAME}:7443/arcgis/home" > /tmp/apphttp
if [ $? != 0 ]; then
    echo "ArcGIS did not start. $?"
    exit 1
fi

echo "Configuring initial site." 
python3 create_new_site.py

exit 0
