#!/bin/bash
yum update -y
yum-config-manager --enable epel
yum install -y noip htop

UPDATE_URL="https://raw.github.com/marcuswhybrow/minecraft-server-manager/master"

wget -q ${UPDATE_URL}/installers/common.sh -O /tmp/msmcommon.sh
source /tmp/msmcommon.sh && rm -f /tmp/msmcommon.sh

function install_log() {
    echo "MSM INSTALL: $*"
}

function install_error() {
    echo "MSM INSTALL ERROR: $*"
    exit 1
}

function update_system_packages() {
    install_log "Updating sources"
    yum update --skip-broken || install_error "Couldn't update packages"
}

function install_dependencies() {
    install_log "Installing required packages"
    yum install screen rsync zip java || install_error "Couldn't install dependencies"
}

function enable_init() {
    install_log "Enabling automatic startup and shutdown"
    chkconfig --add msm
}

function config_installation() {
    msm_user_system=true
    install_log "Install directory: ${msm_dir}"
    install_log "New system user to be created: ${msm_user}"
}

install_msm


ln -s /etc/init.d/msm /usr/bin/msm
