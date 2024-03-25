FROM ubuntu-server:latest
LABEL maintainer="brian@wildsong.biz"
ENV REFRESHED_AT 2024-03-22

EXPOSE 6080 6443
# If you are not using a Docker network to connect containers
# you might want to expose these ports, too.
# EXPOSE 1098 4000 4001 4002 4003 4004 6006 6099

# Refer to ESRI docs; this expands limits for user arcgis.
ADD limits.conf /etc/security/limits.conf

# Add the repository for Postgres client
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main" >> /etc/apt/sources.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
# -- This is for ArcGIS 11.0, 11.1
RUN apt-get update && apt-get install -y postgresql-client-14
# -- This is for ArcGIS 11.2 
#RUN apt-get update && apt-get install -y postgresql-client-15

WORKDIR /app

ADD bashrc .

# This script will run create_new_site.py.
ADD start.sh .

# ESRI uses this in some scripts (including 'backup')
ENV LOGNAME arcgis

#VOLUME ["/home/arcgis/directories"]

WORKDIR ${HOME}

# The installer will not run as root. It just exits.
USER arcgis

# Command that will be run by default when you do "docker run" 
CMD /app/start.sh
# && tail -f ./server/framework/etc/service_error.log

#HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -sS --insecure 127.0.0.1:6443 || exit 1
