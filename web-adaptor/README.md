# web-adaptor
Builds an ESRI "ArcGIS Web Adaptor" Docker image that runs on Tomcat + Ubuntu.

## The Web Adaptor

In keeping with the Docker concept, there will be only one service per
container, this one builds the "Web Adaptor". You will need to run additional
containers to get the ArcGIS Server and Portal for ArcGIS services
and connect the services over network connections.

Web Adaptor is pretty useless without either ArcGIS Server or Portal for ArcGIS.
Build and start those first, then come back here.

## Build the Docker Image

You need to have a file downloaded from ESRI to build this docker image.

* Put the Linux installer downloaded from ESRI into the same file with Dockerfile;
this will be a file with a name like Web_Adaptor_Java_Linux_1051_156442.tar.gz

This component does not require any special licensing so unlike Server and Portal,
you won't need any *.prvc file this time.

Now you that you have added the proprietary file in the right place
you can build an image,
 ```
 docker build -t geoceg/web-adaptor .
 ```
(The github repo is "geo-ceg", but Docker repo is "geoceg". This is not a typo.)

### Create a network

If you are going to create dockers for a datastore and for Portal for ArcGIS,
then you need to connect them over a docker network. Then you pass that as
a command line in run commands.

 sudo docker network create wildsong.lan

### Run the command

You have to start "Portal For ArcGIS" first so that Web Adaptor can
find it.  The following commands and scripts assume that Portal is
running in a container called "portal-for-arcgis".

Running in detached mode (as a daemon); as a convenience there is a script called startwa:
```
 docker run -d --name web-adaptor \
   -p 80:8080 -p 443:8443  --net wildsong.lan \
  --link portal-for-arcgis:portal.localdomain \
   geoceg/web-adaptor
```
Once the server is up you can connect to it via bash shell if you want.
 ```
 docker exec -it web-adaptor bash 
 ```

When running in detached mode, the "startwa.sh" script inside the container will run
automatically and it will configure Web Adaptor to connect to your Portal.

### DNS NAME LOOKUPS HAVE TO WORK!!!

Let me say that again.

DNS NAME LOOKUPS HAVE TO WORK.

Everything goes just fine until your web adaptor configures itself and
then cannot find the portal.  Then everything just FAILS.

So far the only thing I have done that will make this work is to make
sure that you have a domain name server running that web-adaptor can
reach that resolves "portal.wildsong.lan" to an address.

I hacked around this problem. I promise that I will fix it eventually
but my goal is to get ArcGIS operational, not to make this Docker
project perfect.

My understanding is that the docker engine should be handling resolution here,
I can "ping" for example and it comes up with the right answer, but the
web adaptor app is bypassing the docker resolver and going out to Bellman (my DNS).
So I have to learn why, maybe tomorrow?

For the moment, I was already running a copy of dnsmasq on my own server.
So all I had to do was figure out what the ip address was for portal and then
create an entry in the dnsmasq server /etc/hosts file, and restart it.

This is what it took for me, in /etc/hosts
```
172.19.0.3	portal portal.wildsong.lan
```
and then after adding that,
```
sudo systemctl restart dnsmasq
```
and now I have a working Web Adaptor.

### Troubleshooting

If you are having problems, (for example the docker command starts and
then exits a few seconds later) run the docker interactively. This
will give you a bash shell instead of launching the server. Then you
can look around at the set up, and manually launch tomcat.  The
messages that you see on your screen will help you figure out what is
wrong.

Run interactively; there is a script containing this called runwa:
```
 docker run -it --rm --name web-adaptor \
  -p 80:8080 -p 443:8443  --net wildsong.lan \
  --link portal-for-arcgis:portal.localdomain \
   geoceg/web-adaptor bash
```

There is a script inside the container called startwa.sh, you have to run it
manually in interactive mode. It starts Tomcat and Web Adaptor and then
configures Web Adaptor so that it can find the Portal.

### Troubleshooting network

There will be a virtual network bridge, do "ifconfig" in your docker host to see the possibilities. It will start with "br"
In my case, "iifconfig |grep ^br" returns
```
br-4bd88be9c4e2: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
```
Then I can watch all traffic flowing on the bridge with
```
sudo tcpdump -i br-4bd88be9c4e2
```
Watching DNS lookups is how I figured out the importance of the resolver issue. Here is one such,

```
14:45:56.061931 IP web-adaptor.wildsong.biz.48698 > bellman.wildsong.biz.domain: 46886+ A? PORTAL.WILDSONG.LAN. (35)
14:45:56.062178 IP bellman.wildsong.biz.domain > web-adaptor.wildsong.biz.48698: 46886* 1/0/0 A 172.19.0.3 (51)
```

## Reverse proxy

I want the Web Adaptor to hide behind a proxy so that I can have one
public site name. I put the Web Adaptor behind a proxy using nginx. I
changed my nginx site configuration, adding this "location" block.

```
	# Always redirect arcgis to secure server
	location /arcgis/ {
	   proxy_pass https://dockerservername/arcgis/;
	   proxy_set_header X-Forwarded-Host $host:$server_port;
	   proxy_set_header X-Forwarded-Server $host;
	   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	}
```
You don't have to have a complete name for the proxy server here, just the
machine the dockers are running on is good enough.

I also added a property setting to Portal, going to the portaladmin page,
system->properties and pasting this in:

```
{"WebContextURL":"https://outside.com/arcgis"}
```

where of course I replaced "outside.com" with my public access site name.

Note your DNS has to resolve this correctly, (or you need "hairpin" set on your router).
I use dnsmasq and just put the host in /etc/hosts on the dns server.


# Files you should know about

Look in the log file /var/log/tomcat8/catalina.out for error messages, 
they can be very detailed and helpful.

See also geo-ceg/docker-tomcat8 for more information.

