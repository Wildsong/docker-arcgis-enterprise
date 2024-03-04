FROM ubuntu-server:latest
LABEL maintainer="brian@wildsong.biz"
ENV REFRESHED_AT 2024-03-04

EXPOSE 2443 
# If you are not using a Docker network to connect containers
# you might want to expose these ports, too.
# EXPOSE 9876 29080 29081 9220 9320

# Change owner so that arcgis can rm later.
RUN chown -R arcgis:arcgis ${HOME}

WORKDIR /app

# Make sure the mount points for the VOLUME command exist before we do
# the "docker run".  I am pretty sure they are created during the
# Setup run (previous RUN) but not certain.  Note: the file ESRI
# installs server/framework/etc/config-store-connections.xml defaults
# to using server/usr/config-store so don't try to move config-store!
#RUN mkdir -p ${HOME}/server/usr

ENV DS_DATADIR ${HOME}/datastore/usr/arcgisdatastore
ENV PGDATA ${HOME}/data/pgdata
# see also elasticdata/ and nosqldata/

# Set path so we can run psql from bash shell
# Note that it's listening on port 7654, so try
# psql -h localhost -p 7654 -U siteadmin gwdb

# Persist data on the host's file system. Make sure these are writable.
#VOLUME ["${DS_DATADIR}"]

# Perhaps if I can set this?
#ENV ESRI_PROP_FILE_PATH=

# Add the script that can create the initial admin user and site
ADD create_new_site.py .

ADD bashrc .
ADD start.sh start.sh

WORKDIR ${HOME}

# Command that will be run by default when you do "docker run"
CMD ["/bin/bash", "/app/start.sh"]
# && tail -f ~/datastore/framework/etc/service_error.log
