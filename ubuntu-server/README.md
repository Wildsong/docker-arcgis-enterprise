# ubuntu-server
Base Ubuntu server

This contains a few extra packages that ArcGIS Server
and Portal for ArcGIS need, to speed up building those images.

It installs packages for python (which is now python3), pip, and uses pip to install "requests", to make it easy to use the ArcGIS REST API.

It creates a user/group called "arcgis/arcgis" with UID/GID of 1000/1000.

## Build

   docker buildx build -t ubuntu-server .

## Run

Just for testing... you can start an instance and use a bash shell to explore. 

   docker run -it --rm ubuntu-server bash

For example you should be able to run python and see something like this.

   root@8eed5bf8768b:~# python
   Python 3.8.10 (default, Jun  2 2021, 10:49:15)
   [GCC 9.4.0] on linux
   Type "help", "copyright", "credits" or "license" for more information.
   >>> import requests
   >>> requests.__version__
   '2.25.1'
   >>>
