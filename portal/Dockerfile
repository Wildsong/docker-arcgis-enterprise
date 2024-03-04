FROM ubuntu-server:latest
LABEL maintainer="brian@wildsong.biz"
ENV REFRESHED_AT 2024-03-04

# Port information: http://server.arcgis.com/en/portal/latest/install/windows/ports-used-by-portal-for-arcgis.htm
EXPOSE 7080 7443

# Probably don't need this for Portal
ADD limits.conf /etc/security/limits.conf

WORKDIR /app

ADD bashrc .
ADD start.sh .

# ESRI uses LOGNAME
ENV LOGNAME arcgis

WORKDIR ${HOME}

# Set path so we can run psql from bash shell
# Note that it's listening on port 7654, so try
# psql -h localhost -p 7654 -U siteadmin gwdb
ENV PATH $PATH:${HOME}/portal/framework/runtime/pgsql/bin

CMD ["/bin/bash", "/app/start.sh"]
# && tail -f portal/usr/arcgisportal/logs/service.log

#HEALTHCHECK --interval=60s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1:7080 || exit 1
