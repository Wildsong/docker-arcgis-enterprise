From ubuntu-server:latest
LABEL maintainer="brian@wildsong.biz"
ENV REFRESHED_AT 2024-03-02
ENV ESRI_VERSION 11.1

# Port information: http://server.arcgis.com/en/portal/latest/install/windows/ports-used-by-portal-for-arcgis.htm
EXPOSE 7080 7443

# Probably don't need this for Portal
ADD limits.conf /etc/security/limits.conf

ENV HOME /home/arcgis

ADD start.sh ${HOME}

RUN chown -R arcgis:arcgis $HOME

# Start in the arcgis user's home directory.
WORKDIR ${HOME}
USER arcgis
# ESRI uses LOGNAME
ENV LOGNAME arcgis

# Create a spot where the volatile content can live
RUN mkdir -p portal/usr/arcgisportal

# Set path so we can run psql from bash shell
# Note that it's listening on port 7654, so try
# psql -h localhost -p 7654 -U siteadmin gwdb
ENV PATH $PATH:${HOME}/portal/framework/runtime/pgsql/bin

HEALTHCHECK --interval=60s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1:7080 || exit 1

CMD cd /home/arcgis && ./start.sh
# && tail -f portal/usr/arcgisportal/logs/service.log
