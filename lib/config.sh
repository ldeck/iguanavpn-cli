#!/usr/bin/env bash

CONFIG=${VPNHOME:-~/.vpn}

if [[ $UID -eq 0 ]]; then
    echo "$0 should not be run as root."
    exit 2;
fi

info() {
   echo "$1" 
}

read_var() {
    read -p "$1: " $1
    echo
}


if [ ! -d $CONFIG ]; then
    echo "Creating $CONFIG"
    mkdir $CONFIG
fi

read_var VPN_NAME
echo "Creating $CONFIG/$VPN_NAME"
mkdir -p "$CONFIG/$VPN_NAME"

read_var VPN_HOST
echo "Creating $CONFIG/$VPN_NAME/host"
echo $VPN_HOME > $CONFIG/$VPN_NAME/host

read_var VPN_USERNAME
echo "Creating $CONFIG/$VPN_NAME/username"
echo $VPN_USERNAME > $CONFIG/$VPN_NAME/username

echo "Enter vpn slices 1 per line:"

VPN_SLICES=$(</dev/stdin)
echo "Creating ${CONFIG}/${VPN_NAME}/slice"
echo "${VPN_SLICES}" > ${CONFIG}/${VPN_NAME}/slice

info "Setup done."
info ""
info "NB: if openconnect says it cannot verify the servercert of the host then do, for example"
info "    echo 'pin-sha256:...' > ${CONFIG}/${VPN_NAME}/servercert"

