PROJECT_DIR := $(CURDIR)
SYSTEMD_DIR := ~/.config/systemd/user

MEM_MAX := 3G
MEM_MIN := 1G

NOW := `date --iso-8601=minutes`
BACKUP_DIR := $(CUR_DIR)/backup

MC_VERSION := 1.17.1
PAPERMC_VERSION := 221

SHELL=/bin/bash
.SHELLFLAGS = -e -o pipefail -c

.PHONY: install
install:
	sudo apt update && sudo apt install -y openjdk-16-jre curl 
	mkdir -p $(SYSTEMD_DIR)
	cat <<"EOF" > $(SYSTEMD_DIR)/papermc.service
## fixme: [ ] が testコマンド扱いになって失敗するバグがある
## fixme: プラグインやpapermcのインストールをしていない
	[Unit]
	Description=Minecraft Server
	After=network-online.target
	[Service]
	TimeoutStopSec=120
	WorkingDirectory=$(CUR_DIR)
	ExecStart=/usr/bin/screen -Dm -S papermc /usr/bin/java -Xmx$(MEM_MAX) -Xms$(MEM_MIN) -jar $(CUR_DIR)/papermc.jar
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

	echo -n 'agree eula? [y/N]: '
	read cmd
	case $cmd in
		"y" | "Y" | "yes" | "Yes" ) echo "eula=true" > $(CUR_DIR)/eula.txt && echo "install success!" ;;
		*) echo "install failed" ;;
	esac

.PHONY: start
start:
	systemctl --user start papermc

.PHONY: stop
stop:
	systemctl --user stop papermc

.PHONY: status
status:
	systemctl --user status papermc

.PHONY: backup
backup:
	systemctl --user stop papermc
	mkdir -p $(BACKUP_DIR)
	tar cvfz $(BACKUP_DIR)/$(NOW) $(CUR_DIR)/world $(CUR_DIR)/world_nether $(CUR_DIR)/world_the_end
	systemctl --user start papermc

.PHONY: update
update:
	systemctl --user stop papermc
	mv $(PROJECT_DIR)/papermc.jar $(PROJECT_DIR)/papermc.jar.bak
## fixme: ファイル名の変更(papermc.jarに), プラグインの更新
	curl -OL https://papermc.io/api/v2/projects/paper/versions/$(MC_VERSION)/builds/221/downloads/paper-$(MC_VERSION)-$(PAPERMC_VERSION).jar
