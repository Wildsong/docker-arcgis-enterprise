# Our hostname is different than when we built this container image,
# Fix up the name of our properties file
ln -s .ESRI.properties.*.${ESRI_VERSION} .ESRI.properties.${HOSTNAME}.${ESRI_VERSION}

ARCGISSERVER="server"
USER="siteadmin"
PASSWD="changeit"

echo "Starting up the datastore server!"
./datastore/startdatastore.sh

sleep 5

echo "Waiting for Datastore server \"${HOSTNAME}\"..."
curl --retry 15 -sS --insecure "https://${HOSTNAME}:2443/" > /tmp/dshttp
if [ $? != 0 ]; then
    echo "Datastore did not start. $?"
    exit 1
fi

echo "Connecting datastore to \"${ARCGISSERVER\"."
cd datastore/tools
./configuredatastore.sh https://${ARCGISSERVER}:6443/ ${USER} ${PASSWD} \
			${DS_DATADIR} \
			--stores relational
# [--stores [relational][,][tileCache][,][spatiotemporal]]

echo "Configuration is now done, theoretically."

exit 0
