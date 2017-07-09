# docker-arcgis-enterprise
A set of dockers for ESRI Arcgis Enterprise

I used to have (a growing number of) separate github repos,
I realized I never intend to use them separately so I combined them
into one repo for all four dockers.

Each of these builds a separate Docker image:

* arcgis-server/
* portal-for-arcgis/
* web-adaptor/
* datastore/

Each of these directories used to be a separate repo docker-*.

Once I get this merge sorted out then I will build a Docker Compose YAML file.

## Create a network

To connect the separate dockers together and enable the use of hostnames
requires creating a custom network.

Use this command:

```
 sudo docker network create arcgis-network
```

Each of the provided scripts in this repo assumes you use
"arcgis-network" as the network name. 

You only have to do this once, it hangs around in your docker engine.

## Build everything

* Download archives from ESRI. Put each tar.gz file in the appropriate folder.
* Create provisioning files for ArcGIS Server and Portal for ArcGIS and put them in their folders.

### or build only what you need

It should be possible to use arcgis-server by itself if you don't need anything else.
It should be possible to use only arcgis-server and datastore

In each folder build an image; this should work...

```
 docker build -t geoceg/arcgis-server arcgis-server
 docker build -t geoceg/portal-for-arcgis portal-for-arcgis
 docker build -t geoceg/arcgis-datastore datastore
 docker build -t geoceg/web-adaptor web-adaptor
```

Each build takes only a few minutes.

I suggest you run each "build" command separately, check for errors in
the output, fix the problems before moving on to the next. You should
only need do this once to create a set of Docker images after
downloading new archives or licenses.

If you don't want to use all the components you can chdir into the
folders you are interested in and read the README.md file there to see
how to build and run them individually.

When you are done you should be able to see each image with

```
 docker images
```

On my machine I see this
```
 REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
 geoceg/arcgis-datastore    latest              d8e61bbe881c        19 minutes ago      2.628 GB
 geoceg/web-adaptor         latest              a7552ece6ded        21 minutes ago      780.9 MB
 geoceg/portal-for-arcgis   latest              1f358fe41e8c        2 hours ago         9.045 GB
 geoceg/arcgis-server       latest              22b64314fb7f        2 hours ago         12.17 GB
 geoceg/ubuntu-server       latest              5087324512da        2 days ago          353.1 MB
 geoceg/tomcat8             latest              5d4e0becef99        6 days ago          443.3 MB
```

## Run everything

Run them using the Docker Compose commands that I have not yet written...
working on it RIGHT NOW!!! 2017-Jul-09

