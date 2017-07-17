#!/bin/bash
#
#  Run this in an ArcGIS container to start the server
#  and configure it with the default admin/password and site
#
# Required ENV settings:
# HOSTNAME HOME ESRI_VERSION

cd $HOME

# Our hostname is different than when we built this container image,
# fix up the name of our properties file
echo My hostname is $HOSTNAME
NEWPROPERTIES=".ESRI.properties.${HOSTNAME}.${ESRI_VERSION}"
PROPERTIES=".ESRI.properties.*.${ESRI_VERSION}"
if ! [ -f "$NEWPROPERTIES" ] && [ -f "$PROPERTIES" ]; then
    echo "Linked $PROPERTIES."
    ln -s $PROPERTIES $NEWPROPERTIES
fi

# Do that brute force thing, remove the directory contents.
CONFIGDIR="./server/usr/config-store"
if [ -e ${CONFIGDIR}/.site ]; then
    echo "Removing previous site configuration files."
    rm -rf ${CONFIGDIR}/* ${CONFIGDIR}/.site
fi

# This would be a good place to authorize a
# license file if you have not done that already
# Check status first
#./server/tools/authorizeSoftware -s

echo "Starting ArcGIS Server"
./server/startserver.sh

# Pause for server to start
sleep 10

echo "Waiting for ArcGIS Server to start..."
curl --retry 20 -sS --insecure "https://$HOSTNAME:6443/arcgis/manager" > /tmp/apphttp
if [ $? != 0 ]; then
    echo "ArcGIS did not start. $?"
    exit 1
fi

echo "Yes; configuring default site." 
python3 create_new_site.py

exit 0
