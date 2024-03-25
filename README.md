# docker-arcgis-enterprise
ESRI ArcGIS Enterprise running in Docker containers on Linux

This project helped me learn vast amounts about how
ArcGIS Enterprise is set up internally. 

It also builds blindingly fast compared to Windows, probably
because it's a fresh install and I have no data needing upgrading.
I use a Linux Desktop running Linux Mint and a 20 core Intel i9 
and 64GB of RAM and a 1TB of NVME storage. That probably helps. :-)

## Status

* Server : working
* Portal : probably working, but I don't have a CREATOR available right now for testing
* Data Store: starts, but useless without a Portal
* Web Adaptor: no longer using it

Enterprise Geodatabase: Currently I am using PostgreSQL, today I used
the project https://github.com/Wildsong/docker-postgres-replication
which was created to test PostgreSQL in a replication mode.

## To do

* Update the wiki
* Use .properties files instead of lots of secrets in environment, and put the files in secrets
* I am thinking about breaking it into a config stage and a run stage,
using two compose YAML files.
* Include some test data including a map or two?
* Document Varnish and PostgreSQL set ups.

## History

March 2024 -- I have temporary use of an 11.0 license so I did extensive updates
on this project based on 6 years of experience with Docker. It's much
simpler and faster to set up.

In 2017, I paid for an Esri development license and worked on putting
ArcGIS Enterprise into Docker. I pretty much had it working when two
things happened, (1) I got a day job and (2) the license ran out.

If I had a license I'd continue to develop it but I am not willing to
pay right now.  If you want me to do more work on it and you have a
developer license, get in touch.  brian@wildsong.biz

## Overview

Check the wiki, https://github.com/Wildsong/docker-arcgis-enterprise/wiki for additional notes.
2024-03 No actually, don't check that wiki, I have not looked at it in a long long time.


These folders contain files to build separate Docker images:

* server/
* portal/
* datastore/
* postgres/

Regarding Postgres - we build our own image for Postgres because we want to use this 
as an Enterprise Geodatabase Server so it needs to have st_geometry.so
installed. That's also why the "old" version of Postgres. (Version 15 is the
highest supported by Esri currently.)

If you don't know what an "Enterprise Geodatabase Server" is, it is a database
server with support for storing Esri ArcGIS geometry data in its tables.

There is a standalone project for Postgres that includes
an administrative interface (PGAdmin) and replication (just for testing!)
See https://github.com/Wildsong/docker-postgres-replication.

## Preparation

### Download archives and unpack them

Go to my.esri.com and log in. Go to the Downloads page. Go to Enterprise for Linux.
Download the components you want to test; Server, Portal, Data Store
and the Postgres geometry file.
You can start with Server and go from there or dive in and download all.

Put everything in the Installers/ folder.

You have to use your own tar archive files, and you have to unpack them. You need
the archive for each component; Portal, Server, Data Store, and Web Adaptor. Unpack them
with the normal tar command, for example this will create a folder "ArcGIS_DataStore_Linux". Repeat for the other components.

   tar xzvf ArcGIS_DataStore_Linux_111_185305.tar.gz

The geometry engine comes in a ZIP file, so this should unzip to "PostgreSQL".

   unzip ArcGIS_Enterprise_112_ST_Geometry_PostgreSQL_188228.zip

The Dockerfiles expect to find folders named like this:

* Installers/ArcGISServer
* Installers/ArcGIS_DataStore_Linux
* Installers/PortalForArcGIS
* Installers/PostgreSQL

### Get license files

You can actually build everything without any licenses but things won't run. :-)

Do whatever you need to do to get your Server and Portal files. 

* You need a "PRVC" provisioning file for Server named "ArcGISServer.prvc".
* You need a JSON license file for Portal named "ArcGISPortal.json".
* Data Store doesn't have any special needs.

These file names are hard coded in compose.yaml, you could change them in there if you want.

When I was using my Esri Developer subscription I had no problems getting whatever files I needed. Currently I have to use an 11.1 license because the my.esri.com website won't let me generate a new 11.2 PRVC file. Whatever. Maybe I will figure 
that out tomorrow. It's not important to me. I don't care what happened 
in the move from 11.1 to 11.2 as long as I can run something.

## Configuration

### Hostnames

I put the hostnames into my DNS server, and I used these:

* server.local
* portal.local
* datastore.local

Currently there is no reason to have a separate hostname for the Postgres container.

If you are working on one machine, you 
could just put them in /etc/hosts. (Or whatever works on Windows, lmhosts I guess.)

For example,

    cat >> /etc/hosts
    127.0.0.1 portal portal.local
    127.0.0.1 server server.local
    127.0.0.1 datastore datastore.local

### Environment settings

Copy sample.env to .env and edit it. Since this is only for testing and experimentation,
I just put it on the ".local" domain. You can change to a real domain, it should be 
possible to do that by only editing ".env".

## Build Docker images

Early versions of this project I baked the installer code right into the image files,
figuring that would make deployment easy. I wanted each image to have a complete, 
running service built into it. 

But this project is not about deployment, it's
about testing and development, so I scrapped that.

Now the unpacked installers are mounted at run time instead. 
The first time you run each container, the service is installed into a Docker volume.
On subsquent startups, the installer is skipped.

#### Build the Ubuntu image

The images for Server, Portal, and Data Store are all 
built on a common "ubuntu-server" image, so first
build that. (This used to be a separate github repo.)

   docker buildx build -t ubuntu-server ubuntu-server

#### Build the ArcGIS images and the Postgres images

Assuming you already have the tar and license folders here (see above)
next build the ArcGIS Docker images.

Build them all, or build them one at a time. In development I built and ran one at a time.

Build them all like this,

   docker-compose build

or build one at a time, for example, build the server component,

   docker-compose build server

Caching note -- If you are afraid changes are not getting commited to the
images when you have edited files, you can add the option "--no-cache" to the build line. But chances are Docker is building correctly and you forgot to do 
"docker compose down" to remove the previous container(s).

When you are done building you should be able to see each image 
with the command "docker images"; on my machine I see this:

   docker images
   REPOSITORY         TAG       IMAGE ID       CREATED        SIZE
   arcgis-server      latest    0b052cdea386   19 hours ago   609MB
   arcgis-datastore   latest    fdee592f8eca   19 hours ago   602MB
   arcgis-portal
   arcgis-postgres

## Run everything or...

I'm using docker-compose, so you should be able to start (in theory) everything with

    docker compose up -d

and they will be running in background because of the -d.

## ..run only one component

Today I'm only working on Data Store, so I can do

   docker compose up datastore

This starts only the datastore and leave it running in foreground so
I can watch the log messages.

Running only the Data Store is only useful when debugging set up,
since it can't do anything useful without Portal.

### Run Server in standalone mode

You *can* run Server as a standalone service (that is, without Portal or Data Store).
If you want, you can start Server and Postgres and set them up. Start pgadmin
too, so you can easily manage the Postgres instance. Here we go,

   docker compose up server postgres pgadmin -d

Server will be running on port 6443, Postgres on its default port 5432,
and I've put Pgadmin on port 8213 (kind of just a random choice, 
change it in compose.yaml if you want.)

At this point you can connect to Server or PGadmin via browser.

#### Set up Postgres

Open a browser to PGadmin, https://localhost:8213/
should work. Login using the credentials you put in .env for PGADMIN.
Register a connection to your running Postgres by right-clicking "Server" and chosing "Register", use the hostname of the computer you are running on and the port 5432.
Create a login/role. I call the user "sde". 
Create a database and make "sde" the owner.

Start up ArcGIS Pro and make a project. Create a new database connection.
Use the geoprocessing tool "Enable Enterprise Database". Have your "keycodes" file ready.
Save an SDE file (one will be automatically created, note its name and location.)

#### Create a site

Once you have a working EGDB (Enterprise Geodatabase) then you can use the
Server Manager to register it as a data store. Login and upload the SDE file you
created in ArcGIS Pro, and it should then show the database as available.

   https://server.local:6443/server/manager/site.html

At this point you should have a functional EGDB and a functional ArcGIS Server.
In ArcGIS Pro, import a feature class and publish to server.

### Other tips on startup

As mentioned above if you are debugging and the build is not putting your changes into the Docker image, it can be frustrating. Use "--no-cache" like this for example,

   docker compose build server --no-cache

But it's probably doing the build correctly and either you've messed up somewhere else or
you are restarting existing containers. Clear out the old containers like this

   docker compose down

Now your changes should show up.

Also keep in mind persistence! For example, once you have run "server" once it will
have installed into a Docker volume. If you want it to completely reinstall you can
delete the volume and make a new one. Of course, there goes all your data and settings too!
Poof! Gone!

## Some debugging notes

I think Esri tracks what is installed in the "Zero G registry" 
which is a file ".com.zerog.registry.xml". I ignore it.
In start.sh I just look for a properties file in /home/arcgis, 
for example, .ESRI.properties.server.local.11.1 when HOSTNAME is set to "server.local".

In Server, InstallAnywhere creates a .Setup folder and puts a log file in it. See ~/server/.Setup/ArcGISServer_InstallLog.log.

## Notes on each component

### Server

There is a password reset command, 

    passwordreset -p *newpassword*

    # Files you should know about

Here is where the authorization codes for software are kept:

    /home/arcgis/server/framework/runtime/.wine/drive_c/Program\ Files/ESRI/License11.0/sysgen/keycodes

### Data Store

Runs a web server on port 2443 and its postgres server on 9876
CouchDB is used for a tile store if you start one, on ports 
29080 and 29081.

The "spatiotemporal big data store" runs on ports 9220 9320
but I've never tried because I have no license for it.

Content gets stored in /home/arcgis/datastore/usr/arcgisdatastore

#### Data store types

*Relational* Required data store type for ArcGIS Enterprise, used by
hosted feature layers, spatial analysis tools, and Insights
for ArcGIS

*Tile Cache* Stores tile caches for hosted scene layers

*Spatiotemporal* Archives real-time data for GeoEvent Server, and stores
output from GeoAnalytics Server tools

#### Connection problem?

On my first attempt to connect to the DataStore server I got this error:
"Attempt to configure data store failed.. Extended error message: The
specified GIS Server site already has a managed data store."
 
I had to open the ArcGIS Server Manager (on port 6443) go to "Site"
tab select "Data Store" in the sidebar and select and delete 
the data store there.

#### Backends

From Desktop run the Create Spatial Type tool

From ArcCatalog you can create a connection to a PostgreSQL database,
then you can "Enable Enterprise Geodatabase". This will ask for an authorization file.
It's looking for a keycodes file, not a PRVC file.

### Portal

Portal does not start up without a license file and since it's not
really starting it does not create the secret Postgres database that
it uses. Or it does not use one on Linux? No idea right now.

Wait for configuration

After launching the site you need to wait for the configuration script to complete.

If you hit the portal site with your browser before it is done configuring itself,
you will probably get the page that says "Create or Join a Portal".

The last thing Portal does in the config process is restart itself, so the message will be similar to this:

```
<Msg time="2017-07-12T21:15:15,134" type="WARNING" code="217064" source="Portal" process="29" thread="1" methodName="" machine="PORTAL.WILDSONG.LAN" user="" elapsed="">The web server was found to be stopped. Re-starting it.</Msg>
```

### Web Adaptor

*2024-03-03 I am not working on it right now.*

There should be two of these, one for Portal and one for Server. Or maybe just one for Portal. What's the deal anyway,
why do I need them at all?

## Resources

You can learn a lot about how ESRI thinks provisioning should be done by reading the source
code from their [Github Chef](https://github.com/Esri/arcgis-cookbook) repository. 

### Create a site

I use a script create_new_site.py but here is
the code that creates a site by using REST. This is ruby code from
arcgis-cookbook/cookbooks/arcgis-enterprise/libraries/server_admin_client.rb
that is pretty easy to read, basically it's filling in a form and sending it.

      log_settings = {
        'logLevel' => log_level,
        'logDir' => log_dir,
        'maxErrorReportsCount' => 10,
        'maxLogFileAge' => max_log_file_age }

      request = Net::HTTP::Post.new(URI.parse(
        @server_url + '/admin/createNewSite').request_uri)

      request.set_form_data('username' => @admin_username,
                            'password' => @admin_password,
                            'configStoreConnection' => config_store_connection.to_json,
                            'directories' => directories.to_json,
                            'settings' => log_settings.to_json,
                            'cluster' => '',
                            'f' => 'json')

      response = send_request(request, @server_url)

      validate_response(response)

You should be able to see the form by going to https://yourserver:6443/admin/createNewSite
