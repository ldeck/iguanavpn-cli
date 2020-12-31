#!/bin/bash

set -o errexit
set -o pipefail

set -e
set -u

VHOME=${VPNHOME:-~/.vpn}
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

read_private() {
    read -sp "$1: " $1
    echo
}

read_option() {
    read -p "$1 [$2]: " $1
    echo
}

usage_config() {
    echo "No vpn configs exist in $VHOME."
    echo "Run setup.sh as non-root"
    exit 2
}

if [ ! -d $VHOME ]; then
    usage_config
fi

COUNT=$(find $VHOME/* -maxdepth 1 -type d | wc -l)
if [[ $COUNT -eq 0 ]]; then
    usage_config
fi


echo "Select your vpn config:";
select VPROFILE in $VHOME/*/; do
    if [ -n "$VPROFILE" ]; then
        VPROFILE=${VPROFILE%/}
        break;
    fi
    echo ">>> Invalid Selection";
done

PASSTYPE=pass+secret
if [ -f $VPROFILE/passtype ]; then
    PASSTYPE=$(<$VPROFILE/passtype)
fi

case $PASSTYPE in
    secret)
        read_private VPN_SECRET
        PASSPHRASE=$VPN_SECRET
        ;;
    *)
        read_private VPN_PASSWORD
        read_private VPN_SECRET
        PASSPHRASE="$VPN_PASSWORD\n$VPN_SECRET"
esac

USE_VPNSLICE=${WITH_VPNSLICE:-false}
echo ">>> with vpnslice: $USE_VPNSLICE"

$DIR/vpn-wrapper.sh $VPROFILE $PASSPHRASE --with-vpnslice=$USE_VPNSLICE
