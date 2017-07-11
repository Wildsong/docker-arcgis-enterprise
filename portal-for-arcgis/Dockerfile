From geoceg/ubuntu-server:latest
LABEL maintainer="b.wilson@geo-ceg.org"
ENV REFRESHED_AT 2017-07-11

# Port information: http://server.arcgis.com/en/portal/latest/install/windows/ports-used-by-portal-for-arcgis.htm
EXPOSE 7080 7443

# Probably don't need this for Portal
ADD limits.conf /etc/security/limits.conf

ENV HOME=/home/arcgis

# Put your license file and a downloaded copy of the server software
# in the same folder as this Dockerfile
ADD *.prvc /home/arcgis
# "ADD" knows how to unpack the tar file directly into the docker image.
ADD Portal_for_ArcGIS_Linux_10*.tar.gz /home/arcgis

# Add the script that can create the initial admin user and site
# I can't actually run the create_new_site.py here because it will have
# the usual problems (server must be running already)
ADD create_new_site.py ${HOME}
#
# Instead this script will run create_new_site.py..
ADD start.sh ${HOME}

# Change owner so that user "arcgis" can remove installer later.
RUN chown -R arcgis:arcgis $HOME

# Start in the arcgis user's home directory.
WORKDIR ${HOME}
USER arcgis
ENV LOGNAME arcgis # ESRI uses this

# Change command line prompt
ADD bashrc ./.bashrc

# Run the ESRI installer script as user 'arcgis' with these options:
#   -m silent         silent mode: don't pop up windows, we don't have a screen anyway
#   -l yes            You agree to the License Agreement
#   -a license_file   Use "license_file" to add your license. It can be a .ecp or .prvc file.
#   -d dest_dir       Default is /home/arcgis/arcgis/portal
RUN whoami && cd PortalForArcGIS && \
    ./Setup -m silent --verbose -l yes -a $HOME/*.prvc -d $HOME
RUN rm -rf PortalForArcGIS

# I tried using a volume to persist setting but failed. There were apparently permission issues.
#VOLUME [ "$HOME/portal/usr/arcgisportal/content" ]

HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1:7080 || exit 1

CMD ./start.sh && tail -f usr/arcgisportal/logs/service.log
