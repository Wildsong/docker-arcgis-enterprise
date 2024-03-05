#!/bin/bash
#
#  Run this in an ArcGIS container to start the Portal server
#  and configure it with the default admin/password and site
#
# Environment: HOSTNAME AGP_USERNAME AGP_PASSWORD PORTAL_CONTENT

source /app/bashrc
cp /app/bashrc /home/arcgis/.bashrc

PROPERTIES=".ESRI.properties.${HOSTNAME}.${ESRI_VERSION}"

# Clumsily wipe all log files so when we start
# there will only be one.
# TODO find the current logfile instead
# amd remove only old logs
LOGDIR="/home/arcgis/portal/usr/arcgisportal/logs"
rm -rf $LOGDIR/PORTAL.LOCAL/portal/*.l??

# Well, maybe if this file is here then it's installed already?
SCRIPT="/home/arcgis/portal/framework/etc/agsportal.sh"
if [ -f $SCRIPT ]; then 
  echo "Portal for ArcGIS is already installed."
else
  echo "Installing Portal"
  /app/Installer/Setup -m silent --verbose -l yes
fi

# Is it running already? 
if [ -f ${SCRIPT} ]; then
  echo "Restarting Portal"
  ${SCRIPT} restart
fi

PORTAL_URL="https://${HOSTNAME}:7443/arcgis/home/"
echo -n "Waiting for Portal to start.. "
sleep 10
curl --retry 6 -sS --insecure --head ${PORTAL_URL} > /tmp/apphttp
if [ $? != 0 ]; then
  echo "Portal not responding. $?"
else
  echo "okay!"
  portaldiag
fi

# Instead of spelling out all these options it is also
# possible to feed a properties file, for example see
# ~/portal/tools/createportal/createportal.properties
# Note that all of these arguments except -d are required, else the script fails 
createportal.sh -fn Site -ln Admin \
		-u ${AGP_USERNAME} -p ${AGP_PASSWORD} \
		-e ${ADMIN_EMAIL} \
		-d ${PORTAL_CONTENT} \
		-lf /app/portal_license.json

CONFIG_STORE="/home/arcgis/portal/framework/etc/config-store-connection.json"
if [ -f $CONFIG_STORE} ]; then
  CreateAdminAccount list
else
  echo "Portal is not configured."
fi

echo "Try reaching me at ${PORTAL_URL}"

tail -f ${LOGDIR}/PORTAL.LOCAL/portal/*.log
