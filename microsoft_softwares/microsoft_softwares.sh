#!/bin/bash
# Visual Studio Code
# Microsoft Edge
source variables.sh

cd $REPO_DIR
sudo cp vscode.repo microsoft-edge.repo /etc/yum.repos.d/
sudo dnf install microsoft-edge-stable code -y &>$REPO_DIR/../log/microsoft_softwares.log
