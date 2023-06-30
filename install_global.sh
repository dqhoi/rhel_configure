#!/bin/sh
REPO_DIR="$(dirname "$(readlink -m "${0}")")"

# General configuration
general_config() {
	all_users=($(cut -d: -f1 /etc/passwd))
	all_groups=($(cut -d: -f1 /etc/group))
	name_user=""
	create_user() {
		user() {
			echo -ne "Type name user normal: "
			read name_user
		}
		user
		check() {
			for user in "${all_users[@]}"; do
				for group in "${all_groups[@]}"; do
					if [ $user == $name_user ] || [ $group == $name_user ]; then
						echo "User already exists"
						user
						check
					fi
				done
			done
		}
		check
	}
	create_user
	sudo adduser $name_user
	sudo passwd -d $name_user
	if [ ! -d "/home/$name_user/Drive" ]; then
		sudo mkdir /home/$name_user/Drive
	fi
	sudo chmod -R 777 /home/$name_user
	cd $REPO_DIR
	cd ..
	cp -R rhel-post-install /home/$name_user/Drive
	sudo chmod -R 777 /home/$name_user
	if [ ! -d "$HOME/Drive" ]; then
		mkdir $HOME/Drive
	fi
	sudo find $(dirname "$(readlink -m "${0}")") -type f -print0 | sudo xargs -0 dos2unix -- &>/dev/null
	if ! grep -q "clean_requirements_on_remove=1" /etc/dnf/dnf.conf; then
		sudo sh -c 'echo -e "directive clean_requirements_on_remove=1" >> /etc/dnf/dnf.conf'
	fi
	sudo dnf install gnome-shell -y
	sudo dnf install gnome-terminal -y
	sudo dnf install gnome-terminal-nautilus nautilus gnome-disk-utility chrome-gnome-shell PackageKit-command-not-found gnome-software gparted gnome-system-monitor podman-compose cockpit-podman cockpit-machines podman -y
	sudo dnf install gdm -y
	sudo dnf install git -y
	sudo dnf install dbus-x11 -y
	sudo dnf install zsh -y
}

# EPEL for Red Hat Enterprise Linux 9.2 (Boot)
rhel_epel() {
	sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
	sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
}

# WiFi for Red Hat Enterprise Linux 9.2 (Boot)
wifi_install() {
	if nmcli device status | grep "ethernet" | grep -q "unavailable"; then
		cd $REPO_DIR/wifi
		wifi_first=$(ls iw*)
		wifi_second=$(ls wireless*)
		wifi_third=$(ls wpa*)
		wifi_fourth=$(ls Network*)
		sudo rpm -ivh $wifi_first $wifi_second $wifi_third $wifi_fourth
		sudo systemctl restart NetworkManager
		sleep 10
		sudo dnf reinstall iw wireless-regdb wpa_supplicant NetworkManager-wifi -y
		sudo dnf upgrade -y
	fi
}

# Visual Studio Code
text_editor() {
	cd $REPO_DIR/repo
	sudo cp vscode.repo /etc/yum.repos.d/
	sudo dnf install -y code
}

# Microsoft Edge
web_browser() {
	cd $REPO_DIR/repo
	sudo cp microsoft-edge.repo /etc/yum.repos.d/
	sudo dnf install microsoft-edge-stable -y
}

# Add custom command to remove kernel old
custom_cmd() {
	sudo cp $REPO_DIR/custom_command/rmkernel /usr/bin
	sudo chmod +x /usr/bin/rmkernel
}

# GDM Setup
gdm_setup() {
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface icon-theme 'rhel'
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface text-scaling-factor '1.25'
	sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'action'
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click 'true'
	sudo -u gdm dbus-launch gsettings set org.gnome.login-screen disable-user-list true
	# user_custom=$(grep "AutomaticLogin=" $REPO_DIR/gdm_conf/custom.conf | awk -F "=" '{print $2}')
	# user_local=$(whoami)
	sudo cp $REPO_DIR/gdm_conf/custom.conf /etc/gdm
	# if [ "$user_custom" != "$user_local" ]; then
	# 	sudo sed -i "s/$user_custom/$user_local/g" /etc/gdm/custom.conf
	# fi
}

# Enable Graphical User Interface
gui_enable() {
	sudo systemctl set-default graphical.target
}

# Remove File and Folder Unnecessary
rmfolder() {
	cd $HOME/Drive
	gcm_file=$(ls gcm*)
	shfmt_file=$(ls shfmt*)
	rm -rf gnome-terminal install.sh $HOME/.oh-my-zsh/themes WhiteSur-gtk-theme WhiteSur-icon-theme WhiteSur-cursors ibus-bamboo fira-code fira-code.zip install-gnome-extensions.sh $gcm_file shfmt $HOME/Drive
	cd /usr/share/themes
	rhel_important=$(ls -d /usr/share/themes/rhel*alt)
	sudo mv $rhel_important /usr/share/themes/redhat-alt
	sudo rm -rf rhel*
	cd redhat-alt
	sudo rm -rf cinnamon plank gnome-shell
	cd $HOME
}

# GRUB Themes Configuration
bootloader() {
	if [ ! -d /boot/grub2/themes ]; then
		sudo mkdir -p /boot/grub2/themes
	fi
	cd $REPO_DIR
	sudo cp -r bootloader /boot/grub2/themes
	if ! grep -q "/boot/grub2/themes/bootloader/theme.txt" /etc/default/grub; then
		sudo sh -c 'echo "GRUB_THEME=\"/boot/grub2/themes/bootloader/theme.txt\"" >> /etc/default/grub'
	fi
	sudo sed -i 's/^\(GRUB_TERMINAL\w*=.*\)/#\1/' /etc/default/grub
	sudo sed -i 's/GRUB_CMDLINE_LINUX="rhgb quiet"/GRUB_CMDLINE_LINUX_DEFAULT=\"intel_idle.max_cstate=1 cryptomgr.notests initcall_debug intel_iommu=igfx_off no_timer_check noreplace-smp page_alloc.shuffle=1 rcupdate.rcu_expedited=1 tsc=reliable quiet splash\"/g' /etc/default/grub
	if ! grep -q "GRUB_FONT=/boot/grub2/fonts/unicode.pf2" /etc/default/grub; then
		sudo sh -c 'echo -e "GRUB_FONT=/boot/grub2/fonts/unicode.pf2" >> /etc/default/grub'
	fi
	sudo cp grub_conf/30_uefi-firmware /etc/grub.d
	sudo chmod 777 /etc/grub.d/30_uefi-firmware
	sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
}

# Remove Packages that are not needed
uninstall() {
	sudo dnf autoremove vim-common vim-enhanced vi -y
}

# Install Theme based MacOS for System
themes() {
	sudo rm -rf /usr/share/themes/redhat-alt
	cd $HOME/Drive/
	git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
	# sudo dnf install vi -y
	cd WhiteSur-gtk-theme
	# vi -u NONE -c 'g/&#panelActivities/normal! d%' -c 'wq' src/sass/gnome-shell/common/_panel.scss
	gawk -i inplace '!/Yaru/' src/main/gnome-shell/gnome-shell-theme.gresource.xml
	sudo ./install.sh -n 'rhel' -o normal -c Dark -a alt -t default -p 60 -P smaller -s default -b default -m -N mojave -HD --normal --round --right -i gnome
	sudo ./tweaks.sh -g default -o normal -c Dark -t default -p 60 -P smaller -n -i gnome -b default
}

# Install Icons based MacOS for System
icons() {
	cd $HOME/Drive/
	git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git
	cd WhiteSur-icon-theme
	sudo ./install.sh -n 'rhel' -t default -a -b
}

# Install Cursor based MacOS for System
cursor() {
	cd $HOME/Drive/
	git clone https://github.com/vinceliuice/WhiteSur-cursors.git
	cd WhiteSur-cursors
	sudo ./install.sh
}

# Vietnamese Type Input
type_input() {
	sudo yum install make go libX11-devel libXtst-devel gtk3-devel -y
	cd $HOME/Drive
	git clone https://github.com/BambooEngine/ibus-bamboo.git
	cd ibus-bamboo
	sudo make install
}

# Install Fira Code Fonts
fonts() {
	cd $HOME/Drive
	wget $(curl -s https://api.github.com/repos/tonsky/FiraCode/releases/latest | grep browser_download_url | cut -d '"' -f 4) -O fira-code.zip
	unzip fira-code.zip -d fira-code
	sudo mkdir -p /usr/share/fonts/fira-code-fonts
	sudo cp fira-code/ttf/FiraCode-SemiBold.ttf /usr/share/fonts/fira-code-fonts
	sudo fc-cache -f -v
	sudo dnf install abattis-cantarell-fonts.noarch adobe-source-code-pro-fonts.noarch dejavu-sans-fonts.noarch dejavu-sans-mono-fonts.noarch dejavu-serif-fonts.noarch fontconfig.x86_64 fontconfig-devel.x86_64 fonts-filesystem.noarch ghostscript-tools-fonts.x86_64 gnome-font-viewer.x86_64 google-droid-sans-fonts.noarch google-noto-cjk-fonts-common.noarch google-noto-emoji-color-fonts.noarch google-noto-fonts-common.noarch google-noto-sans-cjk-ttc-fonts.noarch google-noto-sans-gurmukhi-fonts.noarch google-noto-sans-sinhala-vf-fonts.noarch google-noto-serif-cjk-ttc-fonts.noarch jomolhari-fonts.noarch julietaula-montserrat-fonts.noarch khmer-os-system-fonts.noarch langpacks-core-font-en.noarch libXfont2.x86_64 liberation-fonts.noarch liberation-fonts-common.noarch liberation-mono-fonts.noarch liberation-sans-fonts.noarch liberation-serif-fonts.noarch libfontenc.x86_64 lohit-assamese-fonts.noarch lohit-bengali-fonts.noarch lohit-devanagari-fonts.noarch lohit-gujarati-fonts.noarch lohit-kannada-fonts.noarch lohit-odia-fonts.noarch lohit-tamil-fonts.noarch lohit-telugu-fonts.noarch paktype-naskh-basic-fonts.noarch pt-sans-fonts.noarch sil-abyssinica-fonts.noarch sil-nuosu-fonts.noarch sil-padauk-fonts.noarch smc-meera-fonts.noarch stix-fonts.noarch thai-scalable-fonts-common.noarch thai-scalable-waree-fonts.noarch urw-base35-bookman-fonts.noarch urw-base35-c059-fonts.noarch urw-base35-d050000l-fonts.noarch urw-base35-fonts.noarch urw-base35-fonts-common.noarch urw-base35-gothic-fonts.noarch urw-base35-nimbus-mono-ps-fonts.noarch urw-base35-nimbus-roman-fonts.noarch urw-base35-nimbus-sans-fonts.noarch urw-base35-p052-fonts.noarch urw-base35-standard-symbols-ps-fonts.noarch urw-base35-z003-fonts.noarch -y
}

# Git Credentials Management
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

# Install shfmt (Format Shell Scripts)
shfmt() {
	mkdir -p $HOME/Drive/shfmt
	cd $HOME/Drive/shfmt
	curl -s https://api.github.com/repos/mvdan/sh/releases/latest | grep "browser_download_url" | grep "linux_amd64" | cut -d : -f 2,3 | tr -d \" | wget -i -
	mv * shfmt
	sudo mv shfmt /usr/bin/
	sudo chmod +x /usr/bin/shfmt
}

# Run Programs
admin_user() {
	wifi_install
	rhel_epel
	general_config
	text_editor
	web_browser
	custom_cmd
	type_input
	bootloader
	themes
	icons
	cursor
	fonts
	gui_enable
	gcm
	shfmt
	gdm_setup
}

admin_user
sh $REPO_DIR/install_local.sh
sudo systemctl enable --now cockpit.socket
rmfolder
uninstall
