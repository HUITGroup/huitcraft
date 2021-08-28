PROJECT_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
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
	bash $(PROJECT_DIR)/runtime/install.sh $(PROJECT_DIR) $(SYSTEMD_DIR) $(MC_VERSION) $(PAPERMC_VERSION) $(MEM_MAX) $(MEM_MIN)

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
	mv $(PROJECT_DIR)/floodgate-spigot.jar $(PROJECT_DIR)/floodgate-spigot.jar.bak
	mv $(PROJECT_DIR)/Geyser-Spigot.jar $(PROJECT_DIR)/Geyser-Spigot.jar.bak
## fixme: ファイル名の変更(papermc.jarに), プラグインの更新
	if [ ! -e $(PROJECT_DIR)/papermc.jar ]; then
		curl -OL https://papermc.io/api/v2/projects/paper/versions/$(MC_VERSION)/builds/221/downloads/paper-$(MC_VERSION)-$(PAPERMC_VERSION).jar
	fi
