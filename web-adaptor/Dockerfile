FROM ubuntu:20.04
LABEL maintainer="brian@wildsong.biz"
ENV REFRESHED_AT 2020-04-17

# Uncomment the right lines for your version. 
ENV ESRI_VERSION 10.7.1
ENV TGZ 1071
#ENV ESRI_VERSION 10.8
#ENV TGZ 108

ENV RELEASE=bionic
# "bionic" is currently the latest Ubuntu LTS (Long Term Support) release.

RUN apt-get update && apt-get -y install apt-utils locales
RUN apt-get -y install iputils-ping curl

# Set up the locale. 
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Note that we can't use tomcat's ports (8080,8443) with Web Adaptor
EXPOSE 80 443

# Default dependencies cause openjdk 11 to be installed
# which is not in the supported list
RUN apt-get install -y openjdk-8-jre-headless tomcat8

# Prerequisites: Before doing a "docker build", 
# put a downloaded copy of the web adaptor installer
# in the same folder as this Dockerfile

# You can override these in docker-compose.yml
ENV WA_NAME web-adaptor.wildsong.lan
ENV PORTAL_NAME portal.wildsong.lan

# NOTE that CATALINA_BASE is where the app server's files live (owned by root)
# and that the unprivileged user (tomcat) has its own HOME (owned by tomcat).
# This is done to accomodate running the installation as an unprivileged user
# and giving ESRI a place to stash the .ESRI properties file.

# "ADD" knows how to unpack the tar file directly into the Docker image.

# ArcGIS installation should be done as an unprivileged user.
ENV TOMCAT=tomcat8
ENV HOME=/home/${TOMCAT}
ENV CATALINA_HOME=/usr/share/${TOMCAT}
RUN mkdir ${HOME} && chown -R ${TOMCAT}.${TOMCAT} ${HOME} && usermod --home ${HOME} ${TOMCAT}

# Note, there is a "tomcat8" string embedded in this script. This needs fixing.
ADD logrotate /etc/logrotate.d/${TOMCAT}
RUN chmod 644 /etc/logrotate.d/${TOMCAT}

# Change from port 8080 to port 80.
RUN sed -i "s/8080/80/" /etc/${TOMCAT}/server.xml
# Remove the redirect
RUN sed -i "s/redirectPort=\"8443\"//g" /etc/${TOMCAT}/server.xml

# Create and install a self-signed certificate.
RUN keytool -genkey -alias tomcat -keyalg RSA -keystore /etc/${TOMCAT}/.keystore \
    -storepass changeit -keypass changeit \
    -dname "CN=Abraham Lincoln, OU=Legal Department, O=Whig Party, L=Springfield, ST=Illinois, C=US"
# Modify server.xml to activate the TLS service
RUN sed -i "s/<Service name=\"Catalina\">/<Service name=\"Catalina\">\n    <Connector port=\"443\" maxThreads=\"200\" scheme=\"https\" secure=\"true\" SSLEnabled=\"true\" keystorePass=\"changeit\" clientAuth=\"false\" sslProtocol=\"TLS\" keystoreFile=\"\/etc\/${TOMCAT}\/.keystore\" \/>/" \
        /etc/${TOMCAT}/server.xml

ENV PIDDIR=/var/run/${TOMCAT}
RUN mkdir ${PIDDIR} && chown ${TOMCAT}.${TOMCAT} ${PIDDIR}


# Set up authbind to allow tomcat to use ports 80 and 443
# (By default, non-privileged users are not allowed to use ports < 1024.)
ENV AUTHBIND=/etc/authbind/byport/
RUN touch ${AUTHBIND}/80 && touch ${AUTHBIND}/443
RUN chown ${TOMCAT} ${AUTHBIND}/80 ${AUTHBIND}/443
RUN chmod 755 ${AUTHBIND}/80 ${AUTHBIND}/443

ADD Web_Adaptor_Java_Linux_${TGZ}*.tar.gz /home/${TOMCAT}/

WORKDIR ${HOME}
USER ${TOMCAT}

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV JSSE_HOME=${JAVA_HOME}/jre
ENV CATALINA_OUT=/var/log/${TOMCAT}/catalina.out
ENV CATALINA_TMPDIR=/tmp/${TOMCAT}
ENV CATALINA_PID=${PIDDIR}/${TOMCAT}.pid
ENV CATALINA_BASE=/var/lib/${TOMCAT}
# Child containers deploy WAR files here.
ENV CATALINA_APPS /var/lib/${TOMCAT}/webapps
# Set heap,memory options here
ENV CATALINA_OPTS="-Djava.awt.headless=true -Xmx128M"

RUN touch ${CATALINA_OUT} && mkdir ${CATALINA_TMPDIR}

# Run the ESRI installer script with these options:
#   -m silent         silent mode: don't pop up windows, we don't have a screen
#   -l yes            Agree to the License Agreement
#   -d target dir     ESRI default puts the files in wrong place
#
RUN cd ${HOME}/WebAdaptor \
 && ./Setup -m silent --verbose -l yes -d ${HOME}

# Deploy the WAR file; requires ROOT.
USER root
RUN cp ${HOME}/arcgis/webadaptor*/java/arcgis.war ${CATALINA_APPS}

# Once we're done with the installer files, we can delete them.
#RUN rm -rf ${HOME}/WebAdaptor

RUN chown -R ${TOMCAT}:${TOMCAT} /var/log/${TOMCAT} ${HOME}

WORKDIR ${HOME}

# Drop privileges, no need to run as root.
USER ${TOMCAT}

# Change command line prompt
ADD bashrc .bashrc

# The hostname will be changed in the final run command,
# so we need to fix up the name of the properties file to match.
RUN mv .ESRI.properties.*.${ESRI_VERSION} .ESRI.properties.${WA_NAME}.${ESRI_VERSION}

# Add a script that can start web adaptor and configure it
ADD start.sh .

# Add a script that can test the connection to the portal.
ADD check_portal.py .

# FIXME There is a web adaptor health URL, I should wedge that in here
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1 || exit 1

# Start Tomcat on low ports, running in foreground (don't daemonize)
CMD ./start.sh && tail -f /var/log/${TOMCAT}/catalina.out
