#!/usr/bin/env bash

PROJECT_DIR=$1
SYSTEMD_DIR=$2
MC_VERSION=$3
PAPERMC_VERSION=$4
MEM_MAX=$5
MEM_MIN=$6

enable -n [ && cat <<"EOF" >$(SYSTEMD_DIR)/papermc.service
[Unit]
Description=Minecraft Server
After=network-online.target
[Service]
TimeoutStopSec=120
WorkingDirectory=$(PROJECT_DIR)
ExecStart=/usr/bin/screen -Dm -S papermc /usr/bin/java -Xmx$(MEM_MAX) -Xms$(MEM_MIN) -jar $(PROJECT_DIR)/papermc.jar
ExecStop=/usr/bin/screen -S papermc -X stuff "say This server will be shutdown in 30s\015"
ExecStop=/bin/sleep 10
ExecStop=/usr/bin/screen -S papermc -X stuff "say This server will be shutdown in 20s\015"
ExecStop=/bin/sleep 10
ExecStop=/usr/bin/screen -S This server -X stuff "say This server will be shutdown in 10s\015"
ExecStop=/bin/sleep 5
ExecStop=/usr/bin/screen -S This server -X stuff "say This server will be shutdown in 5s\015"
ExecStop=/bin/sleep 5
ExecStop=/usr/bin/screen -S papermc -X stuff "save-all\015"
ExecStop=/usr/bin/screen -S papermc -X stuff "stop\015"
Restart=always
[Install]
WantedBy=multi-user.target
EOF

enable [

if [ ! -e $(PROJECT_DIR)/papermc.jar ]; then
	curl -oL papermc.jar https://papermc.io/api/v2/projects/paper/versions/$(MC_VERSION)/builds/221/downloads/paper-$(MC_VERSION)-$(PAPERMC_VERSION).jar
fi
if [ ! -e $(PLUGINS_DIR)/floodgate-spigot.jar ]; then
	curl -oL floodgate-spigot.jar https://ci.opencollab.dev//job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/target/floodgate-spigot.jar
fi
if [ ! -e $(PLUGINS_DIR)/Geyser-Spigot.jar ]; then
	curl -oL Geyser-Spigot.jar https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastStableBuild/artifact/bootstrap/spigot/target/Geyser-Spigot.jar
fi

echo -n 'agree eula? [y/N]: '
read cmd
case $cmd in
"y" | "Y" | "yes" | "Yes") echo "eula=true" >$(PROJECT_DIR)/eula.txt && echo "install success!" ;;
*) echo "install failed" ;;
esac
