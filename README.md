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