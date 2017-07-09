#
#  Send a very generic request to configure a site to ArcGIS Server.
#
from __future__ import print_function()
import os
import requests

class arcgis(object):

    _defaultpath = "/home/arcgis/server/usr"

    def __init__(self):
        return

    def create_site(self, user, passwd):
        
        # Form contents gleaned from ESRI ArcGIS Chef Cookbooks in Github.

        log_settings = {
            'logLevel' : log_level,
            'logDir'   : os.path.join(self._defaultdir, "logs"),
            'maxErrorReportsCount' : 30,
            'maxLogFileAge' : 100,  # I wonder what units... seconds? centuries?
        }

        form_data = {
            "username"              : user,
            "password"              : passwd,
            "configStoreConnection" : os.path.join(self._defaultpath,"config-settings"),
            "directories"           : os.path.join(self._defaultpath,"directories"),
            
            "settings" : log_settings,
            "cluster"  : "",
            "f"        : "json"
        }

        uri = "https://arcgis-server.localdomain/arcgis/admin/createNewSite"

        response = None
        try:
            r = requests.post(uri,data=form_data)
            print("Response", r.status_code)
        except Exception as e:
            print("Failed to create site:",e)
            return False
        
        return true

# ------------------------------------------------------------------------

if __name__ == "__main__":

    try:
        u = os.environ["AGS_USER"]
        p = os.environ["AGS_PASSWORD"]
    except KeyError:
        u = "siteadmin"
        p = "changeit"

    ag = arcgis()
    if ag.create_site(u,p):
        print("Site created.")

# That's all!
