From geoceg/ubuntu-server:latest
LABEL maintainer="b.wilson@geo-ceg.org"
ENV REFRESHED_AT 2017-07-09

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
ADD ArcGIS_Server_Linux_105*.tar.gz ${HOME}
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
VOLUME ["${HOME}/server/usr/config-store", "${HOME}/server/usr/directories", \
       "${HOME}/server/usr/logs", \
       "${HOME}/server/framework/runtime/.wine/drive_c/Program\ Files/ESRI/License10.5/sysgen"]

# Change command line prompt
ADD bashrc ./.bashrc

HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1:6080 || exit 1

# Command that will be run by default when you do "docker run" 
CMD ./server/startserver.sh && tail -f ./server/framework/etc/service_error.log
