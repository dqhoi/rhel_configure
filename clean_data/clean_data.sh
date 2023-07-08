#!/bin/bash
# Clean Data
source variables.sh

clean_data() {
	cd $REPO_DIR/../downloads
	gcm_file=$(ls gcm*)
	shfmt_file=$(ls shfmt*)
	rm -rf gnome-terminal install.sh $HOME/.oh-my-zsh/themes WhiteSur-gtk-theme WhiteSur-icon-theme WhiteSur-cursors ibus-bamboo fira-code fira-code.zip install-gnome-extensions.sh $gcm_file shfmt
	cd /usr/share/themes
	rhel_important=$(ls -d /usr/share/themes/rhel*alt)
	sudo mv $rhel_important /usr/share/themes/redhat-alt
	sudo rm -rf rhel*
	cd redhat-alt
	sudo rm -rf cinnamon plank gnome-shell
	sudo dnf autoremove vim-common vim-enhanced vi -y
	cd $HOME
}

clean_data &> $REPO_DIR/../log/clean_data.log