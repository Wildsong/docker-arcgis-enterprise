From geoceg/ubuntu-server:latest
LABEL maintainer="b.wilson@geo-ceg.org"
ENV REFRESHED_AT 2017-12-27
ENV ESRI_VERSION 10.6

EXPOSE 2443 
# If you are not using a Docker network to connect containers
# you might want to expose these ports, too.
# EXPOSE 9876 29080 29081 9220 9320

# "ADD" knows how to unpack the tar file directly into the docker image.
ADD ArcGIS_DataStore_Linux_106*.tar.gz ${HOME}

# Change owner so that arcgis can rm later.
RUN chown -R arcgis:arcgis ${HOME}

USER arcgis
WORKDIR ${HOME}

# Run the ESRI installer script as user 'arcgis' with these options:
#   -m silent         silent mode: don't pop up windows, we don't have a screen
#   -l yes            Agree to the License Agreement
RUN cd ArcGISDataStore_Linux && ./Setup -m silent --verbose -l yes -d /home

# Make sure the mount points for the VOLUME command exist before we do
# the "docker run".  I am pretty sure they are created during the
# Setup run (previous RUN) but not certain.  Note: the file ESRI
# installs server/framework/etc/config-store-connections.xml defaults
# to using server/usr/config-store so don't try to move config-store!
#RUN mkdir -p ${HOME}/server/usr

# After Setup is complete, delete installer to free up space.  
# If you are a developer you might want to leave it to get access to diagnostics, see
# http://server.arcgis.com/en/server/latest/administer/linux/checking-server-diagnostics-using-the-diagnostics-tool.htm
RUN rm -rf ${HOME}/ArcGISDataStore_Linux

ENV DS_DATADIR ${HOME}/datastore/usr/arcgisdatastore
ENV PGDATA ${HOME}/data/pgdata
# see also elasticdata/ and nosqldata/

# Set path so we can run psql from bash shell
# Note that it's listening on port 7654, so try
# psql -h localhost -p 7654 -U siteadmin gwdb
ENV PATH $PATH:${HOME}/datastore/framework/runtime/pgsql/bin

# Persist data on the host's file system. Make sure these are writable.
#VOLUME ["${DS_DATADIR}"]

# Perhaps if I can set this?
#ENV ESRI_PROP_FILE_PATH=

# Change command line prompt
ADD bashrc .bashrc

# Add script to start service
ADD start.sh start.sh
ADD federate.py federate.py
# Script that changes a string to uppercase, because of HOSTNAME in logfiles
ADD UPPER.py ${HOME}/

# Command that will be run by default when you do "docker run"
CMD ./start.sh && tail -f ~/datastore/framework/etc/service_error.log
