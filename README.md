# docker-arcgis-enterprise
A set of dockers for ESRI Arcgis Enterprise

Make sure you check the wiki, https://github.com/Geo-CEG/docker-arcgis-enterprise/wiki

There were 4 separate github repos for this project, they have been combined
into one repo for all four dockers.

Each of these folders contains files to build a separate Docker image:

* arcgis-server/
* portal-for-arcgis/
* web-adaptor/
* datastore/

(Each of these directories used to be a separate repo docker-*.)

## Create a network

To connect the separate dockers together and enable the use of hostnames
requires creating a custom network.

Use this command:

```bash
  docker network create arcgis.net
```

Each of the provided scripts in this repo assumes you use
"arcgis.net" as the network name.

You only have to do this once, it hangs around in your docker engine.

## Build everything

* Download archives from ESRI. Put each tar.gz file in the appropriate folder.
* Create provisioning files for ArcGIS Server and Portal for ArcGIS and put them in their folders.

(For testing only, it is also possible to build these containers
without the propietary ESRI files, and that's what will happen on
hub.docker.com once I get things sorted out.)

### Build the containers using Docker Compose

````bash
  docker-compose build
````

When you are done you should be able to see each image with

```bash
 docker images
```

On my machine I see this
```bash
  REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
  geoceg/datastore           latest              2b61b9429659        2 minutes ago       2.835 GB
  geoceg/web-adaptor         latest              ab34fd0cdea5        4 minutes ago       1.156 GB
  geoceg/portal-for-arcgis   latest              e2e69bac2ca6        5 minutes ago       9.252 GB
  geoceg/arcgis-server       latest              eae45e398fac        16 minutes ago      12.39 GB
```

## Run everything

My intention is to start them all at once. For the moment you need to cd into each folder and issue the run command there.
Each folder has a script. The run* script runs in interactive mode, the start* script in detached mode. So far I have
been starting each component in interactive mode in a separate window so that I can watch what happens and can start
and stop them independently.

So, in
window #1, cd arcgis-server && ./runags
window #2, cd portal-for-arcgis && ./runportal
window #3, cd web-adaptor && ./runwa
window #4, cd datastore && ./runds

As you run each component, you will get instructions on what to do and a command prompt. For example,
to start arcgis-server from the command prompt you will be instructed to run the start script, ./start.sh
The session would look something like this:

```bash
  $ cd arcgis-server
  $ ./runags 
  Docker is starting in interactive mode.
  Management URL is http://laysan:6080/arcgis/manager
  Start AGS and configure it with  ./start.sh
  ArcGIS Server$ ./start.sh 
  My hostname is server.arcgis.net
  Removing previous site configuration files.
  Starting ArcGIS Server
  Attempting to start ArcGIS Server... Hostname change detected, updating properties...
  
  
  Waiting for ArcGIS Server to start...
  Yes; configuring default site.
 Error: HTTPSConnectionPool(host='server', port=6443): Read timed out. (read timeout=30)
  A timeout here might not mean anything. Try accessing your server.
```

At this point you should be able to bring up the server in a browser
(use the URL printed by the script) and log into it. Default username
is 'siteadmin' and the password is 'changeit'. You can override these
by defining AGS_USERNAME and AGS_PASSWORD in the environment before
you run the start.sh script.

Open additional windows and start the other components
(portal-for-arcgis, web-adaptor, datastore).

## Resources

You can learn a lot about how ESRI thinks provisioning should be done by reading the source
code from their [Github Chef](https://github.com/Esri/arcgis-cookbook) repository. For example, here is
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
