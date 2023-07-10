#!/bin/bash 
# Vietnamese Type Input
source variables.sh

type_input() {
	sudo yum install make go libX11-devel libXtst-devel gtk3-devel -y
	cd $HOME/Drive
	git clone https://github.com/BambooEngine/ibus-bamboo.git
	cd ibus-bamboo
	sudo make install
}

type_input &> $HOME/Drive/logs/type_input.log