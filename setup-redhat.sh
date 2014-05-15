#!/bin/bash
sudo yum update -y
sudo yum-config-manager --enable epel
sudo yum install -y noip htop

UPDATE_URL="https://raw.github.com/marcuswhybrow/minecraft-server-manager/master"

wget -q ${UPDATE_URL}/installers/common.sh -O /tmp/msmcommon.sh
source /tmp/msmcommon.sh && rm -f /tmp/msmcommon.sh

function install_log() {
    echo "MSM INSTALL: $*" >>/tmp/msminstall.log
}

function install_error() {
    echo "MSM INSTALL ERROR: $*" >>/tmp/msminstall.log
    exit 1
}

function update_system_packages() {
    install_log "Updating sources"
    sudo yum update --skip-broken || install_error "Couldn't update packages"
}

function install_dependencies() {
    install_log "Installing required packages"
    sudo yum install screen rsync zip java || install_error "Couldn't install dependencies"
}

function enable_init() {
    install_log "Enabling automatic startup and shutdown"
    sudo chkconfig --add msm
}

function config_installation() {
    msm_user_system=true
    install_log "Install directory: ${msm_dir}"
    install_log "New system user to be created: ${msm_user}"
}

install_msm


sudo ln -s /etc/init.d/msm /usr/bin/msm
