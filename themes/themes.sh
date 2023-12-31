#!/bin/bash
# Install Themes based MacOS for System
source variables.sh

themes() {
	sudo rm -rf /usr/share/themes/redhat-alt
	cd $HOME/Drive
	git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
	# sudo dnf install vi -y
	cd WhiteSur-gtk-theme
	# vi -u NONE -c 'g/&#panelActivities/normal! d%' -c 'wq' src/sass/gnome-shell/common/_panel.scss
	gawk -i inplace '!/Yaru/' src/main/gnome-shell/gnome-shell-theme.gresource.xml
	sudo ./install.sh -n 'rhel' -o normal -c Dark -a alt -t default -p 60 -P smaller -s default -b default -m -N mojave -HD --normal --round --right -i gnome
	sudo ./tweaks.sh -g default -o normal -c Dark -t default -p 60 -P smaller -n -i gnome -b default
}

themes &>$HOME/Drive/logs/themes.log
