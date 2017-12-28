From geoceg/ubuntu-server:latest
LABEL maintainer="b.wilson@geo-ceg.org"
ENV REFRESHED_AT 2017-12-27
ENV ESRI_VERSION 10.6

EXPOSE 6080 6443
# If you are not using a Docker network to connect containers
# you might want to expose these ports, too.
# EXPOSE 1098 4000 4001 4002 4003 4004 6006 6099

# Refer to ESRI docs; this expands limits for user arcgis.
ADD limits.conf /etc/security/limits.conf

ENV HOME /home/arcgis

# Put your license file and a downloaded copy of the server software
# in the same folder as this Dockerfile
ADD *.prvc ${HOME}

# "ADD" knows how to unpack the tar file directly into the docker image.
ADD ArcGIS_Server_Linux_106*.tar.gz ${HOME}

# Add the script that can create the initial admin user and site
# I can't actually run the create_new_site.py here because it will have
# the usual problems (server must be running already)
ADD create_new_site.py ${HOME}

# Instead this script will run create_new_site.py..
ADD start.sh ${HOME}

RUN chown -R arcgis.arcgis ${HOME}

# Start in the arcgis user's home directory.
WORKDIR ${HOME}
USER arcgis
# ESRI uses this in some scripts (including 'backup')
ENV LOGNAME arcgis

# Run the ESRI installer script as user 'arcgis' with these options:
#   -m silent         silent mode: don't pop up windows, we don't have a screen
#   -l yes            Agree to the License Agreement
RUN cd ArcGISServer && ./Setup -m silent --verbose -l yes

# After Setup is complete, delete installer to free up space.  
# If you are a developer you might want to leave it to get access to diagnostics, see
# http://server.arcgis.com/en/server/latest/administer/linux/checking-server-diagnostics-using-the-diagnostics-tool.htm
RUN rm -rf ${HOME}/ArcGISServer

# Persist ArcGIS Server's data on the host's file system. Make sure these are writable by container.
VOLUME ["${HOME}/server/usr/config-store", \
        "${HOME}/server/usr/directories", \
        "${HOME}/server/usr/logs"]

# Change command line prompt
ADD bashrc ./.bashrc

# Hmmm I wonder if I should check the HTTP or HTTPS service??
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1:6080 || exit 1

# Command that will be run by default when you do "docker run" 
CMD ./start.sh && tail -f ./server/framework/etc/service_error.log
