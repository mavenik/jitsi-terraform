echo "Starting to install Jibri" >> /debug.txt
export JIBRI_AUTH_PASSWORD="${jibri_auth_password}"
export JIBRI_RECORDER_PASSWORD="${jibri_recorder_password}"

# Install generic linux packages for sound
DEBIAN_FRONTEND=noninteractive apt install -yq linux-generic >> /debug.txt

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
apt install -y ffmpeg curl alsa-utils icewm xdotool xserver-xorg-input-void xserver-xorg-video-dummy build-essential libpcre3 libpcre3-dev libssl-dev libnginx-mod-rtmp stunnel4>> /debug.txt

# Install Jibri
apt install -y jibri >> /debug.txt

systemctl enable jibri
usermod -aG adm,audio,video,plugdev,www-data jibri

# Configure Jicofo for Jibri
cat <<~SIP >> /etc/jitsi/jicofo/sip-communicator.properties
org.jitsi.jicofo.jibri.PENDING_TIMEOUT=90
org.jitsi.jicofo.jibri.BREWERY=JibriBrewery@internal.auth.$HOSTNAME
~SIP

# Configure Jitsi Meet to enable streaming and recording controls
sed -e 's/\/\/ liveStreamingEnabled: .*,/liveStreamingEnabled: true,/' -e "s/\/\/ fileRecordingsEnabled: .*,/fileRecordingsEnabled: true,/" -e "s/makeJsonParserHappy/hiddenDomain: 'recorder.$HOSTNAME',\n&/" -i /etc/jitsi/meet/$HOSTNAME-config.js

# Configure Jibri
sed -e '/"username".*$/d' -e '/"password".*$/d' -e "s/prod.xmpp.host.net/$HOSTNAME/g" -e "s/\"auth.xmpp.domain\",/\"auth.$HOSTNAME\", \"username\": \"jibri\", \"password\": \"$JIBRI_AUTH_PASSWORD\"/g" -e "s/internal.auth.xmpp.domain/internal.auth.$HOSTNAME/g" -e "s/\"recorder.xmpp.domain\",/\"recorder.$HOSTNAME\", \"username\": \"recorder\", \"password\": \"$JIBRI_RECORDER_PASSWORD\"/g" -e 's/\/path\/to\/finalize_recording.sh/\/usr\/share\/jitsi-meet\/scripts\/finalize_recording.sh/g' -e "s/\"xmpp\.domain\"/\"$HOSTNAME\"/" -i /etc/jitsi/jibri/config.json

# Setup directory to house recordings
rm -rf ${recorded_stream_dir}
mkdir -p ${recorded_stream_dir}
chown -R www-data:www-data ${recorded_stream_dir}
chmod -R 775 ${recorded_stream_dir}

# Set up a finalize script
cat <<~FINALIZERECORDING > /usr/share/jitsi-meet/scripts/finalize_recording.sh
#!/bin/bash
RECORDING_FILE_DIR=\$1
mv -v \$RECORDING_FILE_DIR ${recorded_stream_dir}/
~FINALIZERECORDING

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

# Simulcast support

# Nginx configuration
cat <<~RTMPNGINX >> /etc/nginx/nginx.conf
rtmp {
  include /etc/nginx/streams-enabled/*;
  }
~RTMPNGINX
mkdir -v /etc/nginx/{streams-available,streams-enabled}
cat <<~RTMPHOST > /etc/nginx/streams-available/$HOSTNAME.conf
server {
  listen 1935;
  chunk_size 4096;
  application live {
    live on;
    ${record_stream}
    ${facebook_stream}
    ${periscope_stream}
    ${youtube_stream} 
    ${twitch_stream}
    ${generic_streams}
  }
}
~RTMPHOST
ln -sf /etc/nginx/streams-available/$HOSTNAME.conf /etc/nginx/streams-enabled/$HOSTNAME.conf

# Set up HTTP access to recordings
apt install -y apache2-utils
echo $ADMIN_PASSWORD | htpasswd -i -c /etc/nginx/.recording_htpasswd $ADMIN_USER
cat <<~RECORDINGLOCATION > recording_location.txt
    location ~ ^/recordings(?:/(.*))?$ {
      alias recording_root_dir/\$1;
      autoindex on;
      access_log /var/log/nginx/recordings.access.log;
      auth_basic "Restricted Area. Use Moderator/Host credentials to access recorded files.";
      auth_basic_user_file /etc/nginx/.recording_htpasswd;
    }
~RECORDINGLOCATION
RECORDING_ROOT_DIR="${recorded_stream_dir}"
ESC_RECORDING_ROOT_DIR=$(echo $RECORDING_ROOT_DIR | sed -e 's/\//\\\//g')
sed -e "s/recording_root_dir/$ESC_RECORDING_ROOT_DIR/" -i recording_location.txt
sed '/error_page 404 \/static\/404\.html/r recording_location.txt' -i /etc/nginx/sites-enabled/$HOSTNAME.conf
rm recording_location.txt

# Configure stunnel for FB Live
sed -e "s/ENABLED=0/ENABLED=1/" -i /etc/default/stunnel4
cat <<~STUNNELCONF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel4/stunnel.pid
output = /var/log/stunnel4/stunnel.log

setuid = stunnel4
setgid = stunnel4

# https://www.stunnel.org/faq.html
socket = r:TCP_NODELAY=1
socket = l:TCP_NODELAY=1

debug = 4

[fb-live]
client = yes
accept = 1936
connect = live-api-s.facebook.com:443
verifyChain = no

~STUNNELCONF

systemctl enable stunnel4

# Create a custom ffmpeg script to proxy RTMP
mkdir -p /opt/util
cat <<~FFMPEGSCRIPT > /opt/util/ffmpeg
#!/bin/bash

COMMAND="/usr/bin/ffmpeg"

while test \$# -gt 0
do
  T="\$1"
  if [ "\$${1:0:32}" == "rtmp://a.rtmp.youtube.com/live2/" ]; then
    # T  will contain the rtmp key from jitsi meet page. Make sure you use the correct IP Address OF the rtmp server you setup earlier
    COMMAND="\$COMMAND rtmp://$HOSTNAME:1935/live/\$${T:32}"
  else
    COMMAND="\$COMMAND \$T"
  fi
  shift
done

echo "RUNNING FFMPEG: «\$COMMAND»."

exec \$COMMAND
PROCESS_FFMPEG=\$!

echo "Esperando finalización del proceso: \$${PROCESS_FFMPEG}."
wait \$PROCESS_FFMPEG
~FFMPEGSCRIPT

chmod +x /opt/util/ffmpeg

# Configure Jibri to use this new script
ESC_PATH=$(echo $PATH | sed -e 's/\//\\\//g')
sed -e "s/\[Service\]/&\nEnvironment=\"PATH=\/opt\/util:$ESC_PATH\"/" -i /etc/systemd/system/jibri.service
systemctl daemon-reload
