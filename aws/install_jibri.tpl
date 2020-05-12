echo "Starting to install Jibri" >> /debug.txt
export JIBRI_AUTH_PASSWORD="${jibri_auth_password}"
export JIBRI_RECORDER_PASSWORD="${jibri_recorder_password}"
echo "Jibri password: $JIBRI_AUTH_PASSWORD $JIBRI_RECORDER_PASSWORD" >> /debug.txt

# Install generic linux packages for sound
apt install -y linux-generic >> /debug.txt

# Configure ALSA Module
echo "options snd-aloop enable=1,1,1,1,1 index=0,1,2,3,4" > /etc/modprobe.d/alsa-loopback.conf
echo "snd-aloop" >> /etc/modules

# Install Chrome
curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add >> /debug.txt
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get -y update >> /debug.txt
apt-get -y install google-chrome-stable >> /debug.txt
mkdir -p /etc/opt/chrome/policies/managed
echo '{ "CommandLineFlagSecurityWarningsEnabled": false }' >>/etc/opt/chrome/policies/managed/managed_policies.json

# Install ChromeDriver
CHROME_DRIVER_VERSION="$(curl -4LS chromedriver.storage.googleapis.com/LATEST_RELEASE)"
wget -N http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P ~/ >> /debug.txt
apt install -y unzip >> /debug.txt
unzip ~/chromedriver_linux64.zip -d ~/ >> /debug.txt
rm ~/chromedriver_linux64.zip
mv -f ~/chromedriver /usr/local/bin/chromedriver
chown root:root /usr/local/bin/chromedriver
chmod 0755 /usr/local/bin/chromedriver

# Install miscellaneous required tools
apt install -y ffmpeg curl alsa-utils icewm xdotool xserver-xorg-input-void xserver-xorg-video-dummy >> /debug.txt

# Install Jibri
apt install -y jibri >> /debug.txt
systemctl enable jibri
usermod -aG adm,audio,video,plugdev jibri

# Configure Jicofo for Jibri
cat <<~SIP >> /etc/jitsi/jicofo/sip-communicator.properties
org.jitsi.jicofo.jibri.PENDING_TIMEOUT=90
org.jitsi.jicofo.jibri.BREWERY=JibriBrewery@internal.auth.$HOSTNAME
~SIP

# Configure Jitsi Meet to enable streaming and recording controls
sed -e 's/\/\/ liveStreamingEnabled: .*,/liveStreamingEnabled: true,/' -e "s/\/\/ fileRecordingsEnabled: .*,/fileRecordingsEnabled: true, hiddenDomain: 'recording.$HOSTNAME',/" -i /etc/jitsi/meet/$HOSTNAME-config.js

# Configure Jibri
sed -e '/"username".*$/d' -e '/"password".*$/d' -e "s/prod.xmpp.host.net/$HOSTNAME/g" -e "s/\"auth.xmpp.domain\",/\"auth.$HOSTNAME\", \"username\": \"jibri\", \"password\": \"$JIBRI_AUTH_PASSWORD\"/g" -e "s/internal.auth.xmpp.domain/internal.auth.$HOSTNAME/g" -e "s/\"recorder.xmpp.domain\",/\"recorder.$HOSTNAME\", \"username\": \"recorder\", \"password\": \"$JIBRI_RECORDER_PASSWORD\"/g" -e 's/\/path\/to\/finalize_recording.sh/\/usr\/share\/jitsi-meet\/scripts\/finalize_recording.sh/g' -e "s/\"xmpp\.domain\"/\"$HOSTNAME\"/" -i /etc/jitsi/jibri/config.json

# Set up a finalize script
echo "#!/bin/bash" > /usr/share/jitsi-meet/scripts/finalize_recording.sh
chmod +x /usr/share/jitsi-meet/scripts/finalize_recording.sh

# Set GRUB to load linux-generic at boot
sed -e 's/GRUB_DEFAULT=0/GRUB_DEFAULT="1>2"/' -i /etc/default/grub
update-grub

# Configure prosody
echo "Configuring prosody for Jibri" >> /debug.txt
PROSODY_CONF_FILE="/etc/prosody/conf.d/$HOSTNAME.cfg.lua"
echo "Prosody Config: $PROSODY_CONF_FILE" >> /debug.txt
cat <<~ENDOFVHOST >> $PROSODY_CONF_FILE

VirtualHost "recorder.$HOSTNAME"
    modules_enabled = {
        "ping";
    }
    authentication = "internal_plain"
~ENDOFVHOST
sed -e "s/Component \"internal.auth.$HOSTNAME\" \"muc\"/&\n    muc_room_cache_size = 1000/" -i $PROSODY_CONF_FILE

echo "Setting Jibri users" >> /debug.txt
prosodyctl --config /etc/prosody/prosody.cfg.lua register jibri auth.$HOSTNAME $JIBRI_AUTH_PASSWORD >> /debug.txt
prosodyctl --config /etc/prosody/prosody.cfg.lua register recorder recorder.$HOSTNAME $JIBRI_RECORDER_PASSWORD >> /debug.txt

