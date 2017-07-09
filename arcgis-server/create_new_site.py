#
#  Send a very generic request to configure a site to ArcGIS Server.
#
#  This returns a response almost instantly but site creation takes
#  several minutes. You can test if from the host (you don't need
#  to be inside the docker container to run it) but hostname
#  has to resolve correctly. Also it probably silently fails... :-)
#
from __future__ import print_function
import os
import requests

hostname = "arcgis-server"

class arcgis(object):

    _defaultdir = "/home/arcgis/server/usr"

    def __init__(self):
        return

    def create_site(self, user, passwd):
        
        # Form contents gleaned from ESRI ArcGIS Chef Cookbooks in Github.

        log_level = "INFO"
        
        log_settings = {
            'logLevel' : log_level,
            'logDir'   : os.path.join(self._defaultdir, "logs"),
            'maxErrorReportsCount' : 30,
            'maxLogFileAge' : 100,  # I wonder what units... seconds? centuries?
        }

        form_data = {
            "username"              : user,
            "password"              : passwd,
            "configStoreConnection" : os.path.join(self._defaultdir,"config-settings"),
            "directories"           : os.path.join(self._defaultdir,"directories"),
            
            "settings" : log_settings,
            "cluster"  : "",
            "f"        : "json"
        }

        uri = "https://%s:6443/arcgis/admin/createNewSite" % hostname

        response = None
        try:
            r = requests.post(uri,data=form_data,
                              timeout=5,
                              verify=False # allow self-signed certificate
            )
            print("Response", r.status_code)
        except Exception as e:
            print("Failed to create site:",e)
            return False
        
        return True

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
