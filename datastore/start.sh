#!/bin/bash
#
# Start the Datastore component
#
# Required ENV settings:
# HOSTNAME HOME ESRI_VERSION
# AGE_SERVER AGE_USERNAME AGE_PASSWORD

if [ "$AGE_USERNAME" = "" -o "$AGE_PASSWORD" = "" -o "$AGE_SERVER" = "" ]
then
    echo "Make sure AGE_USERNAME, AGE_PASSWORD, AGE_SERVER"
    echo "are defined in the environment and try again."
    exit 1
fi

source /app/bashrc

if [ "$DS_DATADIR" == "" ]; then 
  # Run the ESRI installer script as user 'arcgis' with these options:
  #   -m silent         silent mode: don't pop up windows, we don't have a screen
  #   -l yes            Agree to the License Agreement
  cd /app/ArcGISDataStore && ./Setup -m silent --verbose -l yes -d /home
fi

echo My hostname is $HOSTNAME

SCRIPT=/home/arcgis/datastore/framework/etc/scripts/arcgisdatastore.sh
if [ -f ${SCRIPT} ]; then
  $SCRIPT restart
fi

echo -n "Waiting for Datastore to become ready "
sleep 10
curl --retry 15 -sS --insecure "https://localhost:2443/" > /tmp/dshttp
if [ $? != 0 ]; then
    echo "Datastore missing!. $? Maybe it's slow to start?"
    exit 1
fi
echo "Yep!"

# Re-running configuredatastore.sh does not appear to damage anything.
# This will create the various and sundry files in the VOLUME "data"
# The "relational" option means it will use its internal postgresql instance.
echo AGE Server = https://${AGE_SERVER}:6443 
echo DS DataDir = ${DS_DATADIR}
configuredatastore.sh https://${AGE_SERVER}:6443 ${AGE_USERNAME} ${AGE_PASSWORD} ${DS_DATADIR} --stores relational
describedatastore.sh

echo "Try reaching me at https://${HOSTNAME}:2443/"
