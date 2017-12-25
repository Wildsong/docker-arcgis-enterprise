# Start the Datastore component
#
# Required ENV settings:
# HOSTNAME HOME ESRI_VERSION

AGS="server.arcgis.net"
PORTAL="portal.arcgis.net"

if [ "$AGS_USER" = "" -o "$AGS_PASSWORD" = "" ]
then
    echo "Define AGS_USER and AGS_PASSWORD in the environment and try again."
    exit 1
fi


# ESRI likes its hostname to be ALL UPPER CASE! but SOMETIMES not
UPPERHOST=`python3 UPPER.py "$HOSTNAME"`

# Our hostname is different than when we built this container image,
# fix up the name of our properties file
echo My hostname is $HOSTNAME
NEWPROPERTIES=".ESRI.properties.${HOSTNAME}.${ESRI_VERSION}"
PROPERTIES=".ESRI.properties.*.${ESRI_VERSION}"
if ! [ -f "$NEWPROPERTIES" ] && [ -f "$PROPERTIES" ]; then
    echo "Linked $PROPERTIES."
    ln -s $PROPERTIES $NEWPROPERTIES
fi

#source datastore/framework/etc/scripts/arcgisdatastore.sh
#IsStoreRunning
#if [ $? -ne 0 ]; then
    # Remove old log files (created in Docker build)
    rm -f ${HOME}/datastore/usr/logs/${UPPERHOST}/server/*.l*

    # Start the datastore
    ./datastore/startdatastore.sh

    sleep 8
#else
#    echo "Datastore is already running"
#fi

# Find the log file. The hostname has to be UPPERCASE, gag me.
# will get in trouble here if there are many log files, need entire datestamp thing
# but we deleted all the logs up above, yikes, what a hack
export LOGFILE="${HOME}/datastore/usr/logs/$UPPERHOST/server/*.log"
echo "Logfile is $LOGFILE"

echo ""
echo -n "Do we have an ArcGIS Server named \"${AGS}\"? "
curl --retry 15 -sS --insecure "https://${AGS}:6443/" > /tmp/agshttps
if [ $? != 0 ]; then
    echo "No? Nothing to do here! $?"
    exit 1
fi
echo "Yep!"

echo -n "Is the Datastore server \"${HOSTNAME}\" ready? "
curl --retry 15 -sS --insecure "https://${HOSTNAME}:2443/" > /tmp/dshttp
if [ $? != 0 ]; then
    echo "Datastore missing!. $? Maybe it's slow to start?"
    exit 1
fi
echo "Yep!"

# Is there already a datastore set up? Re-running does not appear to damage anything.
# This will create the various and sundry files in the VOLUME "data"
# The "relational" option means it will use its internal postgresql instance.
# [--stores [relational][,][tileCache][,][spatiotemporal]]
cd datastore/tools
./configuredatastore.sh https://${AGS}:6443 ${AGS_USER} ${AGS_PASSWORD} ${DS_DATADIR} --stores relational
./describedatastore.sh

#cd ~
#python3 federate.py $PORTAL $AGS

exit 0
