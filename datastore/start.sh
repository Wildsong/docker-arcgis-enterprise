# Start the Datastore component
#
# Required ENV settings:
# HOSTNAME HOME ESRI_VERSION

AGS="server.arcgis.net"
PORTAL="portal.arcgis.net"
USER="siteadmin"
PASSWD="changeit"

# Our hostname is different than when we built this container image,
# fix up the name of our properties file
echo My hostname is $HOSTNAME
NEWPROPERTIES=".ESRI.properties.${HOSTNAME}.${ESRI_VERSION}"
PROPERTIES=".ESRI.properties.*.${ESRI_VERSION}"
if ! [ -f "$NEWPROPERTIES" ] && [ -f "$PROPERTIES" ]; then
    echo "Linked $PROPERTIES."
    ln -s $PROPERTIES $NEWPROPERTIES
fi

# Start the datastore
./datastore/startdatastore.sh

sleep 8

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
    echo "Datastore missing!. $?"
    exit 1
fi
echo "Yep!"

# Introduce ArcGIS Server and DataStore
cd datastore/tools
./configuredatastore.sh https://${AGS}:6443/ ${USER} ${PASSWD} \
			${DS_DATADIR} \
			--stores relational

# Now how do I tell Datastore about postgis?

# [--stores [relational][,][tileCache][,][spatiotemporal]]

#cd ~
#python3 federate.py $PORTAL $AGS

exit 0
