#!/bin/bash
#
#  Run this in an ArcGIS container to start the Portal server
#  and configure it with the default admin/password and site
#
cd /home/arcgis/

# This would probably be a good place to put code to authorize a
# license file if you have not done that already
# Check status first
#./server/tools/authorizeSoftware -s

echo "Starting Portal ArcGIS"
./portal/startportal.sh

# Pause for server to start
sleep 5

echo "Waiting for Portal server to start..."
curl --retry 15 -sS --insecure "https://portal:7443/arcgis/home" > /tmp/apphttp
if [ $? != 0 ]; then
    echo "ArcGIS did not start. $?"
    exit 1
fi

echo "Yes; configuring default site." 
python3 create_new_site.py

exit 0
