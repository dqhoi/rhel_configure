#!/bin/bash
source variables.sh

general_config() {
	dir_general="$REPO_DIR/.."
	sudo find $dir_general -type f -print0 | sudo xargs -0 dos2unix --
	main1() {
	sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
	# Extra Packages for Enterprise Linux 9.2 (EPEL)
	sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
	sudo dnf install gnome-shell gnome-terminal gnome-terminal-nautilus nautilus gnome-disk-utility chrome-gnome-shell PackageKit-command-not-found gnome-software gnome-system-monitor podman-compose cockpit-podman cockpit-machines podman gdm git dbus-x11 zsh -y
	sudo chsh -s /bin/zsh $USER
	if [ ! -d "$HOME/Drive" ]; then
		mkdir $HOME/Drive
	fi
	if ! grep -q "clean_requirements_on_remove=1" /etc/dnf/dnf.conf; then
		sudo sh -c 'echo -e "directive clean_requirements_on_remove=1" >> /etc/dnf/dnf.conf'
	fi
	sudo systemctl set-default graphical.target
	sudo systemctl enable --now cockpit.socket
	}
	main1 >> $HOME/Drive/logs/general_config.log 2>&1
}

general_config &> $HOME/Drive/logs/general_config.log