# docker-arcgis-enterprise
ESRI ArcGIS Enterprise running in Docker containers on Linux

This project helped me learn vast amounts about how ArcGIS Enterprise
is set up internally. 

It also builds blindingly fast compared to Windows. 
I use a Linux Desktop running Linux Mint and a 20 core Intel i9 and 64GB of RAM
and a 1TB of NVME storage. That probably helps. :-)

## To do

* Remove all the outdated startup files and READMEs
* There is a race condition, datastore needs to wait for Server to be ready.
* PATH is not set the way I want. Set it in Dockerfile??
* Set up Postgres as an Enterprise Geodatabase store.
* Manage logs somehow; ideally push logs to STDOUT so that docker log commands work.
* Include some test data including a map or two?
* Figure out how to use license codes instead of provisioning files.
* Remove hardcoded Esri version number, this should be pretty easy.

## History

March 2024 -- I have temporary use of an 11.1 license so I did extensive updates
on this project based on 6 years of experience with Docker. It's much
simpler and faster to set up.

Back in 2017, I paid for an Esri development license and worked on
putting ArcGIS Enterprise into Docker. I pretty much had it working when
two things happened, (1) I got a day job and (2) the license ran out.

If I had a license I'd continue to develop it but I am not willing to pay right now.
If you want me to do more work on it and you have a developer license, drop me a line.

## Overview

Check the wiki, https://github.com/Wildsong/docker-arcgis-enterprise/wiki for additional notes.

These folders contains files to build a separate Docker image:

* arcgis-server/
* portal-for-arcgis/
* web-adaptor/
* datastore/

## Preparation

### Download archives and unpack them

Go to my.esri.com and log in. Go to the Downloads page. Go to Enterprise for Linux.
Download the components you want to test; Server, Portal, DataStore, Web Adaptor.
You can start with Server and go from there or dive in and grab all four.

You have to use your own tar archive files, and you have to unpack them. You need
the archive for each component; Portal, Server, DataStore, and Web Adaptor. Unpack them
with the normal tar command, for example

   tar xzvf ArcGIS_DataStore_Linux_111_185305.tar.gz

This will create a folder "ArcGIS_DataStore_Linux". Repeat for the other components.
I expect to find folders named

* ArcGISServer
* 
* ArcGIS_DataStore_Linux

### Get license files

You can actually build everything without any licenses but things won't run. :-)

Do whatever you need to do to get your Server and Portal files. 

* You need a "PRVC" provisioning file for Server named "ArcGISServer.prvc".
* You need a JSON license file for Portal named "ArcGISPortal.json".
* DataStore and Web Adaptors don't have any special needs.

These file names are hard coded in compose.yaml, you could change them in there if you want.

When I was using my Esri Developer subscription I had no problems getting whatever files I needed. Currently I have to use an 11.1 license because the my.esri.com website won't let me
generate a new 11.2 PRVC file. Whatever. Maybe I will figure that out tomorrow.
It's not important to me. I don't care what happened in the move from 11.1 
to 11.2 as long as I can run something.

You can use a license code (whatever they call those? The ones like "ECP1235678") 
instead of provisioning files in theory but in the interests of making this as 
automated as possible I only set it up to use the files.

## Configuration

### Hostnames

I put the hostnames into my Pihole DNS server, and I used these:

* server.local
* portal.local
* daatstore.local

You could use some other DNS resolver like dnsmasq or if you are working on one machine, you 
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

### Build the images using Docker Compose

Build them all, or build them one at a time. In development I build and run one at a time.

Build them all like this,

   docker-compose build

or build one at a time, for example, build the server component,

   docker-compose build server

Caching note -- If you are afraid changes are not getting commited to the images when you have
edited files, you can add the option "--no-cache" to the build line. But chances
are Docker is building correctly and you forgot to do "docker compose down".

When you are done building you should be able to see each image 
with the command "docker images"; on my machine I see this:

   docker images
   REPOSITORY         TAG       IMAGE ID       CREATED        SIZE
   arcgis-server      latest    0b052cdea386   19 hours ago   609MB
   arcgis-datastore   latest    fdee592f8eca   19 hours ago   602MB

I'd see more but I am still working on this project. :-) This is it for now.

## Run everything

I'm using docker-compose, so you should be able to start (in theory) everything with

    docker compose up -d

and they will be running in background because of the -d.

Today I'm only working on Datastore, so I do

   docker compose up datastore

This starts only the datastore and leave it running in foreground so
I can watch the log messages.

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
