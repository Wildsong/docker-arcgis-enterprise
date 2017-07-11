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
PORTAL_FQDN="portal.arcgis.net"
WA_FQDN="web-adaptor.arcgis.net"

echo "Is Tomcat running?"
curl --retry 3 -sS "http://127.0.0.1/arcgis/webadaptor" > /tmp/apphttp 2>&1
if [ $? == 7 ]; then
    echo "No Tomcat! Launching.."
    authbind --deep -c bin/catalina.sh start
    sleep 3
else
    echo "Yes - Tomcat is running."
fi

echo -n "Testing HTTP on ${PORTAL_FQDN}.. "
curl --retry 3 -sS "http://${PORTAL_FQDN}:7080/arcgis/home" > /tmp/portalhttp 2>&1
if [ $? != 0 ]; then
    echo "HTTP Portal not reachable, start portal and re-run this."
    exit 1
else
    echo "ok!"
fi

echo -n "Testing HTTPS on ${PORTAL_FQDN}.. "
curl --retry 3 -sS --insecure "https://${PORTAL_FQDN}:7443/arcgis/home" > /tmp/portalhttps 2>&1
if [ $? != 0 ]; then
    echo "HTTPS Portal is not reachable, start portal and re-run this."
    exit 1
else
    echo "ok!"
fi

echo -n "Testing HTTPS on ${WA_FQDN}.. "
# Retry a few times in case tomcat is slow starting up
curl --retry 5 -sS --insecure "https://${WA_FQDN}/arcgis/webadaptor" > /tmp/apphttps 2>&1
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
curl --retry 3 -sS --insecure "https://${WA_FQDN}/arcgis/home" > /tmp/waconfigtest 2>&1
if [ $? == 0 ]; then
    grep -q "Could not access any Portal machines" /tmp/waconfigtest
    if [ $? == 0 ]; then 
        echo "attempting to register Portal ${PORTAL_FQDN}..."
        cd arcgis/webadapt*/java/tools
        ./configurewebadaptor.sh -m portal -u ${USER} -p ${PASS} -w https://${WA_FQDN}/arcgis/webadaptor -g https://${PORTAL_FQDN}:7443
    else
        echo "Portal is already registered!"
    fi
    echo "Now try https://127.0.0.1/arcgis/home in a browser."
else
    echo "Could not reach Web Adaptor at ${WA_FQDN}."
fi
