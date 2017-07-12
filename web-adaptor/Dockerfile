From geoceg/tomcat8:latest
LABEL maintainer="b.wilson@geo-ceg.org"
ENV REFRESHED_AT 2017-07-12

EXPOSE 80 443

# Prerequisites: Before doing a "docker build", 
# Put a downloaded copy of the web adaptor installer
# in the same folder as this Dockerfile

# Tomcat's home directory is in /usr/share so it's not owned by tomcat.
# That means the next steps require root privileges.
USER root

ENV WA_NAME web-adaptor.arcgis.net
ENV PORTAL_NAME portal.arcgis.net

# "ADD" knows how to unpack the tar file directly into the Docker image.
ADD Web_Adaptor_Java_Linux_*.tar.gz ${HOME}

# Run the ESRI installer script with these options:
#   -m silent         silent mode: don't pop up windows, we don't have a screen
#   -l yes            Agree to the License Agreement
#   -d target dir     ESRI puts the files in wrong place (nested in arcgis/ folder)
RUN cd ${HOME}/WebAdaptor && ./Setup -m silent --verbose -l yes -d ${HOME}

# Deploy the WAR file to Tomcat
RUN cp ${HOME}/arcgis/webadaptor*/java/arcgis.war ${WEBAPPS}

# We're done with the installer files, delete them.
#RUN rm -rf ${HOME}/WebAdaptor

RUN chown -R ${TOMCAT}:${TOMCAT} /var/log/${TOMCAT} ${HOME}/.ESRI* ${HOME}

# I wonder what I have to rename here?
# RUN mv .ESRI.proper...

WORKDIR ${HOME}

# Change command line prompt
ADD bashrc .bashrc

# Drop privileges, no need to run as root.
USER ${TOMCAT}

# Add a script that can start web adaptor and configure it
ADD start.sh .

# FIXME There is a web adaptor health URL, I should wedge that in here
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -sS 127.0.0.1 || exit 1

CMD ./start.sh && tail -f /var/log/${TOMCAT}/catalina.out
