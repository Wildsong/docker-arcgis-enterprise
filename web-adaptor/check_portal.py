#
#  Check out our portal machine via the miracle of API calls.
#
# See docs at 
# http://resources.arcgis.com/en/help/arcgis-rest-api/index.html#/Machines/02r3000002pt000000/

from __future__ import print_function
import os, time
import requests
import json

# HTTPS calls will generate warnings about the self-signed certificate if you delete this.
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

class arcgis(object):

    def __init__(self, user, passwd):
        # either of these should work
        self.base_uri = "http://%s:7080/arcgis/portaladmin/"
        #self.base_uri = "https://%s:7443/arcgis/portaladmin/"

        self.user = user
        self.passwd = passwd
        return

    def health(self, hostname):
        uri = self.base_uri % hostname + "healthCheck"
        response = None
        parameters = { "f" : "json" }
        try:
            response = requests.get(uri, params=parameters, timeout=5, verify=False)
            #print("url: %s response: %s" % (response.url,response.text))
            rj = json.loads(response.text)
            status = rj["status"]
            if status != "success":
                print("healthcheck status =",status)
                return False
        except Exception as e:
            print(e)
            return False

        return True

    def machine_status(self, machine):
        uri = self.base_uri + "status/" + machine
        print(uri)

        form_data = {
            "f" : "json"
        }
        response = None
        try:
            response = requests.post(uri, data=form_data, timeout=5, verify=False)
            print("response: %s" % response.text)
            rj = json.loads(response.text)
            status = rj["status"]
            print("status=",status)
        except Exception as e:
            print(e)
            return False

        return True

    def machines(self, hostname):
        uri = self.base_uri % hostname + "machines" + "/?f=json"
        print(uri)

        response = None
        try:
            response = requests.get(uri, timeout=5, verify=False)
            print("response: %s" % response.text)
            rj = json.loads(response.text)
            status = rj["status"]
        except Exception as e:
            print(e)
            return False

        return True

# ------------------------------------------------------------------------

if __name__ == "__main__":

    try:
        portalname = os.environ["PORTAL_NAME"]
    except KeyError:
        portalname = 'portal.arcgis.net'
        print("PORTAL_NAME not set, using default \"%s\"." % portalname)

    try:
        u = os.environ["AGS_USER"]
        p = os.environ["AGS_PASSWORD"]
    except KeyError:
        u = "siteadmin"
        p = "changeit"

    ag = arcgis(u,p)
    if ag.health(portalname):
#        ag.get_token(portalname)
#        ag.machines(portalname)
#    ag.machine_status(machine)
        print("%s says it's okay" % portalname)
        exit(0)
    print("FAILED health check on %s" % portalname)
    exit(1)

# That's all!
