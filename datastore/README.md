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
