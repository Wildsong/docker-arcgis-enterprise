#!/bin/bash
#
#  Run this in an ArcGIS container to install and start the server
#  and configure it with the default admin/password and site
#
# Required ENV settings:
# HOSTNAME HOME ESRI_VERSION

echo My hostname is $HOSTNAME and my Server version is $ESRI_VERSION

if [ "$AGS_USERNAME" = "" -o "$AGS_PASSWORD" = "" ]
then
    echo "Define AGS_USERNAME and AGS_PASSWORD in the environment to override defaults."
    #exit 1
fi

source /app/bashrc
cd /home/arcgis

PROPERTIES=".ESRI.properties.${HOSTNAME}.${ESRI_VERSION}"

UNINSTALLER="/home/arcgis/server/uninstall_ArcGISServer"
# Has the server been installed yet?
SCRIPT="/home/arcgis/server/framework/etc/scripts/agsserver.sh"
if [ -f $SCRIPT ]; then
  echo "ArcGIS Server is already installed."
  $SCRIPT status
  #rm -rf server .ESRI.properties* .com.zerog.registry.xml
  authorizeSoftware -s
else
  cd /app/ArcGISServer && ./Setup --verbose -l yes -m silent
  authorizeSoftware -f /app/authorization.prvc
fi

serverinfo

echo "Starting ArcGIS Server"
$SCRIPT restart

# Pause for server to start
echo "Waiting for ArcGIS Server to start..."
sleep 15
curl --retry 20 -sS --insecure "https://$HOSTNAME:6443/arcgis/manager" > /tmp/apphttp
if [ $? != 0 ]; then
    echo "ArcGIS did not start. $?"
    exit 1
fi

# Is a site configured?
#
echo "Yes; configuring default site." 
/app/create_new_site.py $HOSTNAME $AGS_USERNAME $AGS_PASSWORD
#fi

exit 0
