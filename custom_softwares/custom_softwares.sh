#!/bin/bash
# Git Credentials Management
# Install shfmt (Format Shell Scripts)
source variables.sh

gcm() {
	cd $HOME/Drive
	gcm_install() {
		curl -s https://api.github.com/repos/git-ecosystem/git-credential-manager/releases/latest | grep "browser_download_url" | grep -v "symbol" | grep "linux" | grep "tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -i -
		gcm_file=$(ls gcm*.tar.gz)
		sudo tar -xvf $gcm_file -C /usr/local/bin
		git-credential-manager configure
	}
	if [ command -v git-credential-manager ] &>/dev/null; then
		git-credential-manager unconfigure
		sudo rm -rf $(command -v git-credential-manager)
		gcm_install
	else
		gcm_install
	fi
	git config --global credential.credentialStore secretservice
}

shfmt() {
	mkdir -p $HOME/Drive/shfmt
	cd $HOME/Drive/shfmt
	curl -s https://api.github.com/repos/mvdan/sh/releases/latest | grep "browser_download_url" | grep "linux_amd64" | cut -d : -f 2,3 | tr -d \" | wget -i -
	mv * shfmt
	sudo mv shfmt /usr/bin/
	sudo chmod +x /usr/bin/shfmt
}

custom_softwares() {
	gcm
	shfmt
}

custom_softwares &>$HOME/Drive/logs/custom_softwares.log
