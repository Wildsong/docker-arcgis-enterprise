From ubuntu:jammy
LABEL maintainer="brian@wildsong.biz"
ENV REFRESHED_AT 2024-03-01

ENV RELEASE=jammy
# "jammy" is version 22.04.4.LTS which is the latest LTS (Long Term Support) release.
# It's also the newest version supported by Esri.

RUN apt-get update && apt-get -y install apt-utils locales

# Set up the locale. 
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# The gettext package is needed to install ArcGIS Server,
# Others can be convenient
RUN apt-get -y install gettext less vim net-tools unzip

# Some useful tools; can't go far without python.
RUN apt-get -y install bind9-host iputils-ping wget python3 python3-pip 
RUN ln -s /etc/alternatives/python /usr/bin/python &&\
    ln -s /usr/bin/python3 /etc/alternatives/python

RUN pip install --upgrade pip && pip install requests

# This will make the system work better and eliminate warnings from the temporal store checks
COPY arcgis.conf /etc/sysctl.d/

# These are needed by Portal For ArcGIS
RUN apt-get -y install libice6 libsm6 libxtst6 libxrender1 dos2unix

# Create the user/group who will run ArcGIS services
# I set them to my own UID/GID so that the VOLUMES I create will be read/write
RUN groupadd -g 1000 arcgis && useradd -m -r arcgis -g arcgis -u 1000
ENV HOME /home/arcgis

RUN chown arcgis.arcgis /home/arcgis
WORKDIR /home/arcgis
VOLUME /home/arcgis

# Note the user is still set to root here, we want this so that
# containers that pull from this one still have root when they start.
