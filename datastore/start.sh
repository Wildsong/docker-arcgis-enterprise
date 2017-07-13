# Our hostname is different than when we built this container image,
# Fix up the name of our properties file
ln -s .ESRI.properties.*.${ESRI_VERSION} .ESRI.properties.${HOSTNAME}.${ESRI_VERSION}

# Start up the datastore server!
./datastore/startdatastore.sh


