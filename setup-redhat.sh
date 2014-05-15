#!/bin/bash
yum update -y
yum-config-manager --enable epel
yum install -y noip htop

UPDATE_URL="https://raw.github.com/marcuswhybrow/minecraft-server-manager/master"
msm_dir="/opt/msm"
msm_user="minecraft"
msm_user_system=false
dl_dir="$(mktemp -d -t msm-XXX)"

function install_log() {
    echo "MSM INSTALL: $*" >>/tmp/msminstall.log
}

function install_error() {
    echo "MSM INSTALL ERROR: $*" >>/tmp/msminstall.log
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



# Verifies existence of or adds user for Minecraft server (default "minecraft")
function add_minecraft_user() {
    install_log "Creating default user '${msm_user}'"
    if $msm_user_system; then
        useradd ${msm_user} --home "$msm_dir"
    else
        useradd ${msm_user} --system --home "$msm_dir"
    fi
}

# Verifies existence and permissions of msm server directory (default /opt/msm)
function create_msm_directories() {
    install_log "Creating MSM directories"
    if [ ! -d "$msm_dir" ]; then
        mkdir -p "$msm_dir" || install_error "Couldn't create directory '$msm_dir'"
    fi
    chown -R $msm_user:$msm_user "$msm_dir" || install_error "Couldn't change file ownership for '$msm_dir'"
}

# Fetches latest msm.conf, cron job, and init script
function download_latest_files() {
    if [ ! -d "$dl_dir" ]; then
        install_error "Temporary download directory was not created properly"
    fi

    install_log "Downloading latest MSM configuration file"
    wget ${UPDATE_URL}/msm.conf -O "$dl_dir/msm.conf.orig" || install_error "Couldn't download configuration file"

    install_log "Downloading latest MSM cron file"
    wget ${UPDATE_URL}/cron/msm -O "$dl_dir/msm.cron.orig" || install_error "Couldn't download cron file"

    install_log "Downloading latest MSM version"
    wget ${UPDATE_URL}/init/msm -O "$dl_dir/msm.init.orig" || install_error "Couldn't download init file"
}

# Patches msm.conf and cron job to use specified username and directory
function patch_latest_files() {
    # patch config file
    install_log "Patching MSM configuration file"
    sed 's#USERNAME="minecraft"#USERNAME="'$msm_user'"#g' "$dl_dir/msm.conf.orig" | \
        sed "s#/opt/msm#$msm_dir#g" | \
        sed "s#UPDATE_URL=.*\$#UPDATE_URL=\"$UPDATE_URL\"#" >"$dl_dir/msm.conf"

    # patch cron file
    install_log "Patching MSM cron file"
    awk '{ if ($0 !~ /^#/) sub(/minecraft/, "'$msm_user'"); print }' \
        "$dl_dir/msm.cron.orig" >"$dl_dir/msm.cron"

    # patch init file
    install_log "Patching MSM init file"
    cp "$dl_dir/msm.init.orig" "$dl_dir/msm.init"
}

# Installs msm.conf into /etc
function install_config() {
    install_log "Installing MSM configuration file"
    install -b -m0644 "$dl_dir/msm.conf" /etc/msm.conf
    if [ ! -e /etc/msm.conf ]; then
        install_error "Couldn't install configuration file"
    fi
}

# Installs msm.cron into /etc/cron.d
function install_cron() {
    install_log "Installing MSM cron file"
    install -m0644 "$dl_dir/msm.cron" /etc/cron.d/msm || install_error "Couldn't install cron file"
    /etc/init.d/cron reload
}

# Installs init script into /etc/init.d
function install_init() {
    install_log "Installing MSM init file"
    install -b "$dl_dir/msm.init" /etc/init.d/msm || install_error "Couldn't install init file"

    install_log "Making MSM accessible as the command 'msm'"
    ln -s /etc/init.d/msm /usr/local/bin/msm
}

# Updates rest of MSM using init script updater
function update_msm() {
    install_log "Asking MSM to update itself"
    /etc/init.d/msm update --noinput
}

# Updates rest of MSM using init script updater
function setup_jargroup() {
    install_log "Setup default jar groups"
    /etc/init.d/msm jargroup create minecraft https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar
}

function install_complete() {
    install_log "Done."
}

function install_msm() {
    config_installation
    add_minecraft_user
    update_system_packages
    install_dependencies
    create_msm_directories
    download_latest_files
    patch_latest_files
    install_config
    install_cron
    install_init
    enable_init
    update_msm
    setup_jargroup
    install_complete
}


install_msm


ln -s /etc/init.d/msm /usr/bin/msm
