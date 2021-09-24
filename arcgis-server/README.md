# arcgis-server
Builds an ESRI "ArcGIS Server" Docker image that runs on Ubuntu Server.
Inspired by the xzdbd/arcgisserver and others.

This page sums up the components in ArcGIS Enterprise:
https://server.arcgis.com/en/server/latest/administer/linux/inside-an-arcgis-server-site.htm

This procedure facilitates my testing with an ESRI Developer license. I can
quickly spin up a copy of ArcGIS Server on a local machine and test ideas.

Be sure you remain in compliance with your ESRI licenses; if you are
licensed for only one copy of ArcGIS Server, you should stop the test
container before starting another copy on a different machine.

## Versions

This build process has been tested with 10.9.
It worked with 10.6 and 10.5 but I moved on.

## Build the Docker Image

You need to have two files downloaded from ESRI to build this docker image.

* Put the Linux installer downloaded from ESRI into the same file with Dockerfile;
this will be a file with a name like ArcGIS_Server_Linux_105_154052.tar.gz.

* Create a provisioning file for ArcGIS Server in your ESRI dashboard and download the file.
It will have an extension of ".prvc". Put the file in the same folder with the Dockerfile.

I am using the Developer license, so to create the .prvc file, I went
to the "my.esri.com" web site, clicked the Developer tab, then clicked
"Create New Provisioning File" in the left nav bar.

* Build the image

Now you that you have added the proprietary files in the right place
you can build an image,

    docker build -t wildsong/arcgis-server .

At the end of the build it will something similar to this

```
ArcGIS for Server is NOT authorized. You will need to run /home/arcgis/server/tools/authorizeSoftware before using ArcGIS Server 10.9.

You will be able to access ArcGIS Server Manager by navigating to http://abff9e7e2995:6080/arcgis/manager.
```

## Note on hostname

Normally the hostname of a docker container changes every time it is run.

This is a problem since the name of the machine is used when you authorize
with the file.

I get around this by not authorizing during the 'build' phase, instead
you have to do it on the first run of a container.

First the hostname gets set from the "run" command in a command line
option. Then, log in and run the authorize command. From then on you should
be okay - as long as you start a new container and change hostname before
the arcgis server starts.

## Run the command

There are three volumes, the config-store directory allow persistence
across sessions. Mounting the "logs" folder makes it possible to check
the log files without having to connect to the container. I am not sure
if there is any benefit in mounting the "directories" volume.

Once the server is up you can connect to it via bash shell If you have
not already done so, now you can authorize the server, too. See next
section "Troubleshooting" for specifics on authorizing.

 ```
 docker exec -it server bash
 ```

### Next steps

If you've been reading 
[http://server.arcgis.com/en/server/latest/install/linux/arcgis-server-system-requirements.htm](ArcGIS System Requirements), then at this point you will be at "Step 5. Logging in to Manager."

## Troubleshooting

If you are having problems, (for example the docker command starts and
then exits a few seconds later) you can change the "-d" option to
"-it", and add "bash" to the end of the command. This will give you a
bash shell instead of launching the server. Then you can look around
at the set up, and manually launch the server with the command
"server/startserver.sh". The messages that you see on your screen will
help you figure out what is wrong. Like this

```
At the command prompt I can start the server and then authorize the server,
that process looks like this:
```
 arcgis@arcgis:~$ hostname
 arcgis.localdomain
 arcgis@arcgis:~$ server/startserver.sh 
 Attempting to start ArcGIS Server... Hostname change detected, updating properties...
 
 
  arcgis@arcgis:~$ server/tools/authorizeSoftware -f _*.prvc -e <<my email address>>
 --------------------------------------------------------------------------
 Starting the ArcGIS Software Authorization Wizard
 
 Run this script with -h for additional information.
 --------------------------------------------------------------------------
 Product          Ver   ECP#           Expires 
 -------------------------------------------------
 arcsdeserver     106   ecp012345678   12-jun-2018
 highwayssvr      106   ecp012345678   12-jun-2018
 roadwayrepsvr    106   ecp012345678   12-jun-2018
 svradv           106   ecp012345678   12-jun-2018
 interopserver    106   ecp012345678   12-jun-2018
 maritimechsvr    106   ecp012345678   12-jun-2018
 jtxserver        106   ecp012345678   12-jun-2018
 prodmapserver    106   ecp012345678   12-jun-2018
 svrenterprise    106   ecp012345678   12-jun-2018
 networkserver    106   ecp012345678   12-jun-2018
 defensesvr       106   ecp012345678   12-jun-2018
 aginspiresvr     106   ecp012345678   12-jun-2018
 datareviewersvr  106   ecp012345678   12-jun-2018
 locrefserver     106   ecp012345678   12-jun-2018
 bathymetrysvr    106   ecp012345678   12-jun-2018
 svradv_4         106   ecp012345678   12-jun-2018
 arcgis@arcgis:~$ 
```

## How to access "ArcGIS Server Manager"

When ArcGIS Server is up and running you can access the Server Manager
with a web browser, navigate to
[https://arcgis.localdomain:6443/arcgis/manager](https://arcgis.localdomain:6443/arcgis/manager).

If you are running outside a firewall, and you need admin access, it
is worth noting that the HTTP service running on port 6080 just
redirects you to the HTTPS port 6443. If you go directly to the 6443
port you won't need to punch a hole for port 6080 in your firewall - just 6443.

Another way to address the firewall issue is to put a proxy in front
and only expose HTTPS on the proxy; I use nginx.

## Resetting the password

From bash command line: server/tools/passwordreset/passwordreset.sh -p <newpassword>

## Moving the Docker image

I don't upload the Docker image to hub.docker.com because it contains licensed code.

If you want to build it on one machine to test it and then deploy to a
server, you have some alternatives.  You could build it all over again, you
could run your own registry and copy it there and then do a "docker
pull", or you could export the image and then copy it over to the
server for deployment.

Since I don't do this very often, (I usually publish everything openly
on Docker Hub), I use option 3, save/load.

On the development machine, you can use the repo name (arcgis-server) 
or the id from 'docker images' command.

 docker images
 docker save -o arcgis-server.tar wildsong/arcgis-server

This makes for a big file, around 11 GB. You could compress it if you
want. Compressing takes a long time, then you have to decompress it
after copying it. I don't do this often so I don't bother. The command
would be "gzip arcgis-server.tar".

Then copy it to the deployment server. 

 scp arcgis-server.tar yourdeploymentserver:
 tar tvf arcgis-server.tar # peek inside the tarball if you want

On the deployment machine, after load you should see it in 'docker images'

 docker load -i arcgis-server.tar
 docker images

You should now be able to use a 'docker run' command as described earlier.

# Files you should know about

Here is where the authorization codes for software are kept.
/home/arcgis/server/framework/runtime/.wine/drive_c/Program\ Files/ESRI/License10.5/sysgen/keycodes

Once I have a working image, I copy the keycodes file to the local folder and then build another
image, this one has keycodes embedded in it so I don't need to run the licensing script each
time I spin up a server.

Here is where the hostname is kept
server/framework/postinstall.dat

