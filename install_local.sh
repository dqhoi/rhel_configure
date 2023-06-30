REPO_DIR="$(dirname "$(readlink -m "${0}")")"
if [ ! -d "$HOME/Drive" ]; then
	mkdir $HOME/Drive
fi
cd $HOME/Drive
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
rm -f ./install-gnome-extensions.sh
wget -N -q "https://raw.githubusercontent.com/ToasterUwU/install-gnome-extensions/master/install-gnome-extensions.sh" -O ./install-gnome-extensions.sh && chmod +x install-gnome-extensions.sh
git clone https://github.com/dracula/gnome-terminal

# Install Oh-My-Zsh
cd $HOME/Drive
declare -a gitarray
gitarray=('zsh-users/zsh-syntax-highlighting.git '$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting'' 'zsh-users/zsh-autosuggestions '$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions'' 'spaceship-prompt/spaceship-prompt.git '$HOME/.oh-my-zsh/custom/themes/spaceship-prompt'' 'TamCore/autoupdate-oh-my-zsh-plugins '$HOME/.oh-my-zsh/custom/plugins/autoupdate'')
sh install.sh --unattended
for i in "${gitarray[@]}"; do
	echo $(git clone https://github.com/$i)
done
ln -s $HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme $HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme

# Gnome Terminal Config
id=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$id/ visible-name $(whoami)
gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$id/ cursor-shape 'ibeam'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy '<Ctrl>C'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-tab '<Ctrl>T'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-window '<Ctrl>N'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ save-contents '<Ctrl>S'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-tab '<Ctrl>W'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-window '<Ctrl>Q'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy-html '<Ctrl>X'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ paste '<Ctrl>V'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ select-all '<Ctrl>A'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ preferences '<Ctrl>P'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find '<Ctrl>F'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find-next '<Ctrl>G'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find-previous '<Ctrl>H'
gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find-clear '<Ctrl>J'
gsettings set org.gnome.desktop.interface enable-hot-corners false
cd $HOME/Drive
cd gnome-terminal
./install.sh -s Dracula -p $(whoami) --skip-dircolors
cd $REPO_DIR/zsh_conf
if [ -f $HOME/.zshrc ]; then
	rm -rf $HOME/.zshrc
fi
cp .zshrc $HOME/.zshrc
chsh -s /bin/zsh

# Acessibility
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
gsettings set org.gnome.desktop.session idle-delay 1800
gsettings set org.gnome.desktop.interface gtk-theme 'redhat-alt'
gsettings set org.gnome.desktop.interface icon-theme 'rhel-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
gsettings set org.gnome.desktop.interface clock-show-date true

# Install GNOME Extensions
cd $HOME/Drive
# Vitals
./install-gnome-extensions.sh -e -o -u 1460
# Burn My Windows
./install-gnome-extensions.sh -e -o -u 4679
# Desktop Icons NG (DING)
./install-gnome-extensions.sh -e -o -u 2087
# Tiling Assistant
./install-gnome-extensions.sh -e -o -u 3733
# Replace Activities text with username
./install-gnome-extensions.sh -e -o -u 5010
# CPU Freq
./install-gnome-extensions.sh -e -o -u 1082

# Add custom keybindings
KEY_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
	"['$KEY_PATH/custom0/', '$KEY_PATH/custom1/', '$KEY_PATH/custom2/', '$KEY_PATH/custom3/', '$KEY_PATH/custom4/', '$KEY_PATH/custom5/']"
# Launch Microsoft Edge
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Microsoft Edge"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "microsoft-edge-stable"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Primary><Alt>E"
# Launch Terminal
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "GNOME Terminal"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "gnome-terminal"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "<Primary><Alt>T"
# Switch Input Method
gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Control>space', 'XF86Keyboard']"

# Sounds
gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true

# Keyboard
gsettings set org.gnome.desktop.input-sources show-all-sources true
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Bamboo::Us')]"

# Mouse
gsettings set org.gnome.desktop.interface locate-pointer true

# Battery
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Clock
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface clock-show-weekday true

# Titlebar Buttons
gsettings set org.gnome.desktop.wm.preferences button-layout "close,minimize,maximize:appmenu"

# Remove unused file
cd $HOME/Drive
gcm_file=$(ls gcm*)
shfmt_file=$(ls shfmt*)
rm -rf gnome-terminal install.sh $HOME/.oh-my-zsh/themes WhiteSur-gtk-theme WhiteSur-icon-theme WhiteSur-cursors ibus-bamboo fira-code fira-code.zip install-gnome-extensions.sh $gcm_file shfmt
