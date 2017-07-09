#!/bin/bash
#
#  Script to run inside the container to start the web adapter.
#  It starts Tomcat, (which deploys the Web Adaptor WAR file,)
#  then runs the script to connect this Web Adaptor to a Portal.
#
#  This is clumsy because it means starting Tomcat as a daemon,
#  then waiting for it to start, then running the ESRI script,
#  and then (in the Dockerfile CMD) sleeping. It would be
#  tidier to start Tomcat in foreground mode instead but that
#  leaves the WebAdaptor unconfigured.
#
#  This script needs to build URLs for both the WebAdaptor
#  and the Portal. I suspect that I could run the configuration
#  over REST from outside the container since the use of
#  URLs implies it could be run from anywhere that has 
#  access to the URLs and the user credentials.

# These need to be moved out to the environment.
USER="siteadmin"
PASS="changeit"

# Check for required environment variables
if [ "${WA_FQDN}" == "" ] || [ "${PORTAL_FQDN}" == "" ]; then
   echo "These have to be defined in the environment"
   echo "WA_FQDN full name of the web adapter"
   echo "PORTAL_FQDN full name of portal"
   exit 1
fi

echo "Is Tomcat running?"
curl --retry 3 -sS "http://${WA_FQDN}/arcgis/webadaptor" > /tmp/apphttp
if [ $? == 7 ]; then
    echo "No Tomcat! Launching.."
    authbind --deep -c bin/catalina.sh start
    sleep 3
else
    echo "Yes - Tomcat is running."
fi

echo -n "Testing HTTP on ${PORTAL_FQDN}.. "
curl -sS "http://${PORTAL_FQDN}:7080/arcgis/home" > /tmp/portalhttp
if [ $? != 0 ]; then
    echo "HTTP Portal not reachable, start portal and re-run this."
    exit 1
else
    echo "ok!"
fi

echo -n "Testing HTTPS on ${PORTAL_FQDN}.. "
curl -sS --insecure "https://${PORTAL_FQDN}:7443/arcgis/home" > /tmp/portalhttps
if [ $? != 0 ]; then
    echo "HTTPS Portal is not reachable, start portal and re-run this."
    exit 1
else
    echo "ok!"
fi

echo -n "Testing HTTPS on ${WA_FQDN}.. "
# Retry a few times in case tomcat is slow starting up
curl --retry 5 -sS --insecure "https://${WA_FQDN}/arcgis/webadaptor" > /tmp/apphttps
if [ $? != 0 ]; then
    echo "HTTPS Web Adaptor service is not running!"
    echo "Did the WAR file deploy? Look in /var/lib/${TOMCAT}/webapps for arcgis."
    exit 1;
else
    echo "ok!"
fi

# Now that we know both Tomcat and Portal are running, we can
# test the registration and configure Web Adaptor if it's needed.

# Portal server will respond through WA if WA is already configured.
echo -n "Checking portal registration with Web Adaptor.. "
curl -sS --insecure "https://${WA_FQDN}/arcgis/home" > /tmp/waconfigtest
if [ $? == 0 ]; then
    grep -q "Could not access any Portal machines" /tmp/waconfigtest
    if [ $? == 0 ]; then 
        echo "attempting to register Portal ${PORTAL_FQDN}..."
        cd arcgis/webadapt*/java/tools
        ./configurewebadaptor.sh -m portal -u ${USER} -p ${PASS} -w https://${WA_FQDN}/arcgis/webadaptor -g https://${PORTAL_FQDN}:7443
    else
        echo "portal is already registered!"
    fi
    echo "Now try https:${WA_FQDN}/arcgis/home in a browser."
else
    echo "Could not reach Web Adaptor via ${WA_FQDN}."
fi
