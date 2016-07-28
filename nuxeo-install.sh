#!/bin/sh -x

# Nuxeo setup
wget -q "http://www.nuxeo.org/static/latest-release/nuxeo,cap,tomcat.zip,7.10" -O /tmp/nuxeo-distribution-tomcat.zip
MARKETPLACE_OUTPUT=/tmp/marketplace-nuxeo-io-manager.zip
wget -q "http://www.nuxeo.org/static/latest-io-release/marketplace,nuxeo,io,manager,zip,0.9" -O $MARKETPLACE_OUTPUT

mkdir -p /tmp/nuxeo-distribution
unzip -q -d /tmp/nuxeo-distribution /tmp/nuxeo-distribution-tomcat.zip
distdir=$(/bin/ls /tmp/nuxeo-distribution | head -n 1)
mkdir -p $NUXEO_HOME
mv /tmp/nuxeo-distribution/$distdir/* $NUXEO_HOME
rm -rf /tmp/nuxeo-distribution*
chmod +x $NUXEO_HOME/bin/nuxeoctl

mkdir -p /var/lib/nuxeo
mkdir -p /var/log/nuxeo
mkdir -p /var/run/nuxeo

chown -R $NUXEO_USER:$NUXEO_USER /var/lib/nuxeo
chown -R $NUXEO_USER:$NUXEO_USER /var/log/nuxeo
chown -R $NUXEO_USER:$NUXEO_USER /var/run/nuxeo
chown -R $NUXEO_USER:$NUXEO_USER $MARKETPLACE_OUTPUT

cat << EOF >> $NUXEO_HOME/bin/nuxeo.conf
nuxeo.log.dir=/var/log/nuxeo
nuxeo.pid.dir=/var/run/nuxeo
nuxeo.data.dir=/var/lib/nuxeo/data
nuxeo.wizard.done=true
EOF

# Install java 8
# Install java
apt-get remove -y --purge openjdk-7-jdk
add-apt-repository -y ppa:webupd8team/java && apt-get update
echo "debconf shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
echo "debconf shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections
apt-get install -y oracle-java8-installer

# Install nuxeo.io MP
echo 'mp-init'
su $NUXEO_USER -m -c "$NUXEOCTL mp-init"
echo 'mp-install'
su $NUXEO_USER -m -c "$NUXEOCTL mp-install --accept true $MARKETPLACE_OUTPUT"
