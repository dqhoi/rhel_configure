#!/bin/bash 
# Vietnamese Type Input
source variables.sh

type_input() {
	sudo yum install make go libX11-devel libXtst-devel gtk3-devel -y
	cd $REPO_DIR/../downloads
	git clone https://github.com/BambooEngine/ibus-bamboo.git
	cd ibus-bamboo
	sudo make install
}

type_input &> $REPO_DIR/../log/type_input.log