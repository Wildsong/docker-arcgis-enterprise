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
