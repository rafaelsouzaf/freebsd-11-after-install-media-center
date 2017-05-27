#!/bin/csh
# 
# BSD 3-Clause License
#
# Copyright (c) 2017, Rafael Souza Fijalkowski <rafaelsouzaf@gmail.com>
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set SO_USERNAME = 'MY_USER'
set TRANSMISSION_USERNAME = 'MY_USER'
set TRANSMISSION_PASSWORD = 'MY_PASSWORD'

if ($SO_USERNAME == "MY_USER") then
	echo "PLEASE EDIT THE SCRIPT AND SET THE VARIABLES"
	exit
endif



printf "\n\n\n\n"
echo "########################################################"
echo "################# INSTALL TRANSMISSION"
echo "################# http://localhost:9091"
echo "########################################################"
mkdir -p /Media/Downloads
pkg install -y  transmission-cli transmission-daemon
sysrc transmission_enable="YES"
sysrc transmission_watch_dir="/Media/Downloads"
sysrc transmission_download_dir="/Media/Downloads"
service transmission onestart
sleep 5
service transmission onestop
sleep 5
pkill -f transmission
pw groupmod transmission -m rafaelsouzaf
pw groupmod rafaelsouzaf -m transmission
sed -i -- 's/\/usr\/local\/etc\/transmission\/home\/Downloads/\/Media\/Downloads/g' /usr/local/etc/transmission/home/settings.json
sed -i -- 's/"rpc-username": ""/"rpc-username": "$TRANSMISSION_USERNAME"/g' /usr/local/etc/transmission/home/settings.json
sed -i -- 's/"rpc-whitelist": "127.0.0.1"/"rpc-whitelist": "0.0.0.0"/g' /usr/local/etc/transmission/home/settings.json
sed -i -- 's/"rpc-whitelist-enabled": true/"rpc-whitelist-enabled": false/g' /usr/local/etc/transmission/home/settings.json
sed -i -- 's/{e954129dc4a487547ff2f75dfa673b84ee4d1d0dnvSTwKjT/$TRANSMISSION_PASSWORD/g' /usr/local/etc/transmission/home/settings.json



printf "\n\n\n\n"
echo "########################################################"
echo "################# INSTALL PLEX MEDIA SERVER"
echo "################# http://localhost:32400/web/"
echo "########################################################"
cd /Media
wget https://downloads.plex.tv/plex-media-server/1.5.6.3790-4613ce077/PlexMediaServer-1.5.6.3790-4613ce077-freebsd-amd64.tar.bz2
tar -vxjf PlexMediaServer-1.5.6.3790-4613ce077-freebsd-amd64.tar.bz2
rm PlexMediaServer-1.5.6.3790-4613ce077-freebsd-amd64.tar.bz2



printf "\n\n\n\n"
echo "########################################################"
echo "################# CREATING A SIMPLE rc.d SCRIPT TO PLEX"
echo "################# STARTS AUTOMATICALLY"
echo "########################################################"
cat <<EOF > /etc/rc.d/plex
#!/bin/sh
. /etc/rc.subr
name="plex"
start_cmd="\${name}_start"
stop_cmd=":"
plex_start() {
	cd /Media/PlexMediaServer-1.5.6/ && ./start.sh
	echo "Plex started."
}
load_rc_config \$name
run_rc_command "\$1"
EOF

chmod +x /etc/rc.d/plex

# add plex service in rc.conf
sysrc plex_enable="YES"

#
# SET PERMISSION FOLDER
#
chmod -R 755 /Media
chown -R "$SO_USERNAME:$SO_USERNAME" /Media
ln -s /Media "/home/$SO_USERNAME/Media"
chown -R "$SO_USERNAME:$SO_USERNAME" "/home/$SO_USERNAME/Media"



printf "\n\n\n\n"
echo "########################################################"
echo "################# READY. Thanks!"
echo "########################################################"
echo "################# PLEX: http://localhost:32400/web/"
echo "################# TRANSMISSION: http://localhost:9091"
echo "########################################################"
exit 1
