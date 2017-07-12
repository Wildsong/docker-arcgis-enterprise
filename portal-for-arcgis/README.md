# portal-for-arcgis
Builds an ESRI "Portal For ArcGIS" Docker image that runs on Ubuntu Server.

## Build the Docker Image

You need to have two files downloaded from ESRI to build this Docker image.

* Put the Linux installer downloaded from ESRI into the same file with Dockerfile;
this will be a file with a name like "Portal_for_ArcGIS_Linux_105_154053.tar.gz".

* Create a provisioning file for Portal For ArcGIS in your ESRI dashboard and download the file.
It will have an extension of ".prvc". Put the file in the same folder with the Dockerfile.

For example, I am using the Developer license, so to create the .prvc
file, I went to the "my.esri.com" web site, clicked the Developer tab,
then clicked "Create New Provisioning File" in the left nav bar.

* Build 

Now that you have added the proprietary files you can build an image, 
```
docker build -t geoceg/portal-for-arcgis .
```

## TROUBLES from the log file, after trying to configure:

<Msg time="2017-07-12T01:56:06,793" type="SEVERE" code="209024"
source="Portal Admin" process="23147" thread="14" methodName=""
machine="PORTAL" user="" elapsed="">The process of creating a new site
failed. Reverting site
creation. com.esri.arcgis.portal.admin.core.PortalException:
com.esri.arcgis.portal.admin.core.PortalException:
com.esri.arcgis.portal.admin.core.PortalException:
java.io.FileNotFoundException:
/home/arcgis/portal/content/items/portal/portal-config.properties (No
such file or directory)</Msg>


## Run the container 

Run detached (as a daemon); for convenience I keep this command in a script, "startportal":
```
  docker run --name=portal --net-alias=portal \
  -d -p 7080:7080 -p 7443:7443 --net arcgis-network \
  geoceg/portal-for-arcgis
```
Run interactively (and stop on exit from command shell);
for convenience I keep this in a script, "runportal":
```
  docker run --name=portal --net-alias=portal \
  -it --rm -p 7080:7080 -p 7443:7443 --net arcgis-network \
  geoceg/portal-for-arcgis bash
```

## How to access "Portal for ArcGIS"

When Portal for ArcGIS is up and running you can access it with a web browser, 
navigate to [https://127.0.0.1:7443/arcgis/home](https://127.0.0.1:7443/arcgis/home).

## Files you should know about

Content: /home/arcgis/portal/usr/arcgisportal/content

ESRI.properties file path: /home/arcgis/.ESRI.properties.portal.10.5.1
where "portal" is the current hostname

After installation it contains something like this:
```
 #Sun Jul 02 22:36:51 UTC 2017
 Z_REAL_VERSION=10.5.1
 Z_ArcGISPortal_INSTALL_DIR=/home/arcgis/portal
 ARCLICENSEHOME=
 ESRI_PROGRAM_FILES=
```
