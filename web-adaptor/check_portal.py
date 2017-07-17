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


    
    def __init__(self, host,type, user, passwd):
        self.type = type
        self.token = None
        if type == 'server':
            self.base_uri = "https://%s:6443/arcgis/" % host
        elif type == 'portal':
            self.base_uri = "https://%s:7443/arcgis/sharing/" % host
            pass
        elif type == 'web-adaptor':
            self.base_uri = "https://%s:443/arcgis/sharing/" % host
            pass
        elif type == 'datastore':
            self.base_uri = "https:%s:6443/arcgis"
            pass

        self.user = user
        self.passwd = passwd

        return

    def health(self):
        uri = self.base_uri + "healthCheck"
        response = None
        parameters = { "f" : "json" }
        try:
            response = requests.get(uri, params=parameters, timeout=5, verify=False)
            #print("url: %s response: %s" % (response.url,response.text))
            parsed = json.loads(response.text)
            status = parsed["status"]
            if status != "success":
                print("healthcheck status =",status)
                return False
        except Exception as e:
            print("health", e)
            return False

        return True

    def info(self):
        uri = self.base_uri + "rest/info"
        response = None
        parameters = { "f" : "json" }
        try:
            response = requests.get(uri, params=parameters, timeout=5, verify=False)
#            print("url:",response.url)
            parsed = json.loads(response.text)
#            print(json.dumps(parsed, indent=4, sort_keys=True))
            auth = parsed["authInfo"]
            self.token_required = auth["isTokenBasedSecurity"]

        except Exception as e:
            print("info",e)
            return False

        return True

    def get_token(self):
        if self.type == 'server':
            uri = self.base_uri + "tokens/generateToken"
        else:
            uri = self.base_uri + "sharing/rest/generateToken"
        
        response = None
        parameters = { "f" : "json",
                       "username": self.user,
                       "password": self.passwd,
                       "client": "requestip",
#                       "ip": "172.18.0.1",
                       "expiration": "2"
        }
        try:
            response = requests.post(uri, data=parameters, timeout=5, verify=False)
            #print("url:",response.url)
            parsed = json.loads(response.text)
            #print(json.dumps(parsed, indent=4, sort_keys=True))
            self.token = parsed["token"]
            self.expires = parsed["expires"]

        except Exception as e:
            print("get_token",e)
            return False

        return True

    def machine_status(self, machine):
        if self.type == 'server':
            uri = self.base_uri + "admin/machines/" + machine
        else:
            return False
        parameters = {
            "f" : "json",
            "token" : self.token,
        }
        response = None
        try:
            response = requests.post(uri, data=parameters, timeout=5, verify=False)
            parsed = json.loads(response.text)
            print(response.url,"=",json.dumps(parsed, indent=4, sort_keys=True))

        except Exception as e:
            print("machine_status",e)
            return False

        return True

    def machines(self):
        if self.type != 'server':
            return False
        
        uri = self.base_uri + "admin/machines"
        if not self.token:
            self.get_token()
        
        parameters = {
            "f" : "json",
            "token" : self.token
        }
        response = None
        try:
            response = requests.get(uri, params=parameters, timeout=5, verify=False)
            parsed = json.loads(response.text)
            print(response.url,"=",json.dumps(parsed, indent=4, sort_keys=True))
            machines = parsed["machines"]
            for m in machines:
                name = m["machineName"]
                url  = m["adminURL"]
                print(name,url)
                self.machine_status(name)

        except Exception as e:
            print("machines",e)
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

    ag = arcgis("laysan", 'server', u,p)
    ag.get_token()
    ag.machines()

    exit(0)
    
    print("Testing info")
    uri = [('laysan', 'server'),
           ('portal.arcgis.net', "portal"),
           #("wa","https://web-adaptor.arcgis.net/arcgis/sharing/") DOES NOT RESPOND
    ]
    for hr,b in uri:
        ag = arcgis(b,u,p)
#        ag.health()

        if ag.info():
            print(hr,"Token required?",ag.token_required)
        else:
            print(hr)
        del ag

    print("Testing get_token")
    uri = [('ags',"https://laysan:6443/arcgis/tokens/generateToken"),
           ('wa', "https://web-adaptor.arcgis.net/arcgis/sharing/rest/generateToken"),
    ]
    for hr,b in uri:
        ag = arcgis(b,u,p)
        token = ag.get_token()
        if token:
              print(hr, ag.expires)
        del ag

# That's all!
