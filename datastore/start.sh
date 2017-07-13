#HOSTNAME is from environment
AGS="server"
PORTAL="portal.arcgis.net"
USER="siteadmin"
PASSWD="changeit"

# Our hostname is different than when we built this container image,
# fix up the name of our properties file
ln -s .ESRI.properties.*.${ESRI_VERSION} .ESRI.properties.${HOSTNAME}.${ESRI_VERSION}

./datastore/startdatastore.sh

sleep 5

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

cd datastore/tools
./configuredatastore.sh https://${AGS}:6443/ ${USER} ${PASSWD} \
			${DS_DATADIR} \
			--stores relational
# [--stores [relational][,][tileCache][,][spatiotemporal]]

python3 federate.py $PORTAL $AGS

exit 0
