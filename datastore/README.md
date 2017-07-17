# datastore
Docker container for the ESRI ArcGIS Enterprise Data Store

# Ports

HTTPSweb management: port 2443.  Data store ports—Relational data store: port 9876.
Tile cache data stores: ports 29080 and 29081.
Spatiotemporal big data stores: ports 9220 and 9320.

Content directory:
/home/arcgis/datastore/usr/arcgisdatastore

Data store types - choose one

Relational
	Required data store type for ArcGIS Enterprise, used by
	hosted feature layers, spatial analysis tools, and Insights
	for ArcGIS

Tile Cache
        Stores tile caches for hosted scene layers

Spatiotemporal
	Archives real-time data for GeoEvent Server, and stores
	output from GeoAnalytics Server tools

On my first attempt to connect to the server I got this error:
"Attempt to configure data store failed.. Extended error message: The
specified GIS Server site already has a managed data store."
 
I had to open the ArcGIS Server Manager (on port 6443)
go to "Site" tab
select "Data Store" in the sidebar
and select and delete the data store there

## Backends

You have to have a database running to function as the DBMS backend,
it is the "data store" used by Data Store.

### PostgreSQL

apt-get install postgresql-9.5

From Desktop run the Create Spatial Type tool

From ArcCatalog you can create a connection to a PostgreSQL database,
then you can "Enable Enterprise Geodatabase". This will ask for an authorization file.
It's looking for a keycodes file not a PRVC file.

### Microsoft SQL Server

Strangely enough Microsoft supports a Docker, read about it:
https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-docker

Download the container image
```
  docker pull microsoft/mssql-server-linux
```

Launch the SQL server and persist its data
```
  docker run -d -e "ACCEPT_EULA=Y" --name=mssql -e "SA_PASSWORD=${MSSQL_PASSWORD}" \
  	 -p 1433:1433 \
  	 -v `pwd`/data/mssql:/var/opt/mssql \
  	 microsoft/mssql-server-linux
```

Connect to the server
```
  docker exec -it mssql bash
```

Run some commands in bash shell
```
  /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ${SA_PASSWORD}
'```



It looks like connecting to MSSQL will be done via the ODBC driver, because I have MSSQL 17 and that's too new for a native client.


I am trying this one

Microsoft ODBC Driver 13.1 for SQL Server (64-bit)