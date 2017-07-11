#
#  Send a very generic request to configure a site to Portal for ArcGIS.
#
#  This returns a response almost instantly but site creation takes
#  longer. You can test if from the host (you don't need
#  to be inside the docker container to run it) but hostname
#  has to resolve correctly. Also it probably silently fails... :-)
#
# See example:  http://server.arcgis.com/en/server/latest/administer/linux/example-create-a-site.htm
# Note the example is for ArcGIS Server not Portal but the concepts are the same.
from __future__ import print_function
import os
import requests
import json

# HTTPS calls will generate warnings about the self-signed certificate if you delete this.
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

hostname = "portal" # localhost would almost always work here I think, or use `hostname` command

class arcgis(object):

    defaultdir = "/home/arcgis/portal"

    def __init__(self):
        return

    def create_site(self, user, passwd):

        # Refer to http://resources.arcgis.com/en/help/arcgis-rest-api/index.html#/Create_Site/02r300000257000000/

        content_store_path = os.path.join(self.defaultdir,"content")
        content_store = {
            "type" : "FileSystem",
            "provider" : "FileSystem",
            "connectionString" : content_store_path
            }
        content_storeJSON = json.dumps(content_store)

        form_data = {
            "username"            : user,
            "password"            : passwd,
            "fullname"            : "Site Administrator",
            "email"               : "brian@wildsong.biz",
            "description"         : "Generic site addministrator account",
            "securityQuestionIdx" : 1,
            "securityQuestionAns" : "Nothing",
            "contentStore"        : content_storeJSON,
            "f" : "json"
        }

        uri = "https://%s:7443/arcgis/portaladmin/createNewSite" % hostname

        response = None
        try:
            response = requests.post(uri, data=form_data,
                                     timeout=30, verify=False # allow self-signed certificate
            )
        except Exception as e:
            print("Error:",e)
            print("A timeout here might not mean anything. Try accessing your server.")
            return False

        if response.status_code != 200:
            print("Server not available; code ", r.status_code)
            return False

        rj = json.loads(response.text)
        try:
            error = rj["error"]
            print("\n".join(error["message"]))
            return False
        except KeyError:
            print("Call returned", response.text)
            
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
        print("Portal site created.")

    print("https://localhost:7443/arcgis/home/")

# That's all!
