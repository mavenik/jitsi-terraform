#!/bin/bash
set -e
export HOSTNAME="${domain_name}"
export EMAIL="${email_address}"
ADMIN_USER="${admin_username}"
ADMIN_PASSWORD="${admin_password}"

echo -e "nameserver 8.8.8.8\nnameserver 8.8.4.4" >> /etc/resolv.conf
# disable ipv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
# set hostname
hostnamectl set-hostname $HOSTNAME
echo -e "127.0.0.1 localhost $HOSTNAME" >> /etc/hosts
apt update
# install Java
apt install -y openjdk-8-jre-headless
echo "JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")" | sudo tee -a /etc/profile
source /etc/profile
# install NGINX
apt install -y nginx
systemctl start nginx.service
systemctl enable nginx.service
# add Jitsi to sources
wget -qO - https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -
sh -c "echo 'deb https://download.jitsi.org stable/' > /etc/apt/sources.list.d/jitsi-stable.list"
apt update
echo -e "DefaultLimitNOFILE=65000\nDefaultLimitNPROC=65000\nDefaultTasksMax=65000" >> /etc/systemd/system.conf
systemctl daemon-reload
# Configure Jits install
debconf-set-selections <<< $(echo 'jitsi-videobridge jitsi-videobridge/jvb-hostname string '$HOSTNAME)
debconf-set-selections <<< 'jitsi-meet-web-config   jitsi-meet/cert-choice  select  "Generate a new self-signed certificate"';

# Debug
echo $EMAIL >> /debug.txt
echo $HOSTNAME >> /debug.txt
cat /etc/resolv.conf >> /debug.txt
whoami >> /debug.txt
cat /etc/hosts >> /debug.txt
# Install Jitsi
apt install -y jitsi-meet >> /debug.txt
# letsencrypt
echo $EMAIL | /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh >> /debug.txt

PROSODY_CONF_FILE=/etc/prosody/conf.d/$HOSTNAME.cfg.lua
sed -e 's/authentication \= "anonymous"/authentication \= "internal_plain"/' -i $PROSODY_CONF_FILE
echo >> $PROSODY_CONF_FILE
echo "VirtualHost \"guest.$HOSTNAME\"" >> $PROSODY_CONF_FILE
echo "    authentication = \"anonymous\"" >> $PROSODY_CONF_FILE
echo "    allow_empty_token = true" >> $PROSODY_CONF_FILE
echo "    c2s_require_encryption = false" >> $PROSODY_CONF_FILE

sed -e "s/\/\/ anonymousdomain: .*$/anonymousdomain: 'guest.$HOSTNAME',/" -i /etc/jitsi/meet/$HOSTNAME-config.js

echo "org.jitsi.jicofo.auth.URL=XMPP:$HOSTNAME" >> /etc/jitsi/jicofo/sip-communicator.properties

# Enable local STUN server
sed -e "s/org\.ice4j\.ice\.harvest\.STUN_MAPPING_HARVESTER_ADDRESSES=.*/org.ice4j.ice.harvest.STUN_MAPPING_HARVESTER_ADDRESSES=$HOSTNAME:5349/" -i /etc/jitsi/videobridge/sip-communicator.properties

echo "Enabling Moderator credentials for $ADMIN_USER" >> /debug.txt
prosodyctl --config /etc/prosody/prosody.cfg.lua register $ADMIN_USER $HOSTNAME $ADMIN_PASSWORD

${jibri_installation_script}

prosodyctl restart &>> /debug.txt
/etc/init.d/jitsi-videobridge2 restart &>> /debug.txt
/etc/init.d/jicofo restart &>> /debug.txt

echo "Setup completed" >> /debug.txt
${reboot_script}
