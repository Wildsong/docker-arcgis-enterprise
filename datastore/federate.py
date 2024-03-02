#!/bin/env python
#
#  Federate ArcGIS Server to Portal and set it as Hosting Server
#
import os, time
import requests
import json

def usage():
    print("federate.py portal_server arcgis_server")
    return

# HTTPS calls will generate warnings about the self-signed certificate if you delete this.
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

class arcgis(object):

    # The installer gets pretty cranky if you try to relocate this
    defaultdir = "/home/arcgis/portal/usr/arcgisportal"

    def __init__(self):
        return

    def status_check(self):
        uri = "https://%s:7443/arcgis/portaladmin/Status" % hostname

        form_data = {
            "f" : "json"
        }
        response = None
        try:
            response = requests.post(uri, data=form_data,
                                     timeout=2,
                                     verify=False # allow self-signed certificate
            )
            print("response: %s" % response.text)
            rj = json.loads(response.text)
            status = rj["status"]
        except Exception as e:
            print(e)
            return False

        return True

    def create_site(self, user, passwd):

        # Refer to http://resources.arcgis.com/en/help/arcgis-rest-api/index.html#/Create_Site/02r300000257000000/

        # First we should see if the site is already configured.

        

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
            "fullname"            : "Wildsong Docker",
            "email"               : "admin@example.com",
            "description"         : "Administrator account created for Docker",
            "securityQuestionIdx" : 1,
            "securityQuestionAns" : "Nothing",
            "contentStore"        : content_storeJSON,
            "f" : "json"
        }

        uri = "https://%s:7443/arcgis/portaladmin/createNewSite" % hostname

        response = None
        timeout = False
        try:
            response = requests.post(uri, data=form_data,
                                     timeout=10,
                                     verify=False # allow self-signed certificate
            )
            if response and response.status_code != 200:
                print("Server not available; code ", r.status_code)
                return False
        except Exception as e:
            print("Error:",e)
            timeout = True

        if timeout:
            print("A timeout error is NORMAL. Configuration will take several more minutes to complete.")
            print("I am going to take a nap, and when I wake up I will see if the config completed.")
            for i in range(10,0,-1):
                print("Zz.. %2d\r" % i, end="")
                time.sleep(3)
                if self.status_check():
                    print("Status OK")

            print("Now I should check and see if your site is properly configured.");
            if self.status_check():
                print("Status OK")

            return False

        try:
            rj = json.loads(response.text)
            error = rj["error"]
            print("\n".join(error["message"]))
            return False
        except Exception as e:
            print(e)
            
        return True

# ------------------------------------------------------------------------

if __name__ == "__main__":

    usage()
    exit(0)

    try:
        portal = sys.argv[1]
        ags = sys.argv[2]
    except KeyError:
        usage()
        exit(1)

    try:
        u = os.environ["AGE_USER"]
        p = os.environ["AGE_PASSWORD"]
    except KeyError:
        u = "siteadmin"
        p = "changeit"
        
    ag = arcgis()
    if ag.federate(u,p):
        print("Federation completed.")

    exit(0)

# That's all!
