#!/usr/bin/env nix-shell
#! nix-shell vpn-wrapper.nix -i bash

set -o errexit
set -o pipefail

set -e
set -u
# set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OPENCONNECT=$(which openconnect)
VPNSLICE=$(which vpn-slice)

WITH_VPNSLICE=true

ERR=31
INFO=32
BOLD=1
NORM=0

out() {
    echo -e "\e[${1};${2}m${@:3}\e[0m"
}
err() {
  out $BOLD $ERR "${@:1}"
}
info() {
    out $NORM $INFO "${@:1}"
}

if [[ $# -lt 2 ]]; then
    err "Usage: $0 <config> <password> [--with-vpnslice=false]";
    exit 1;
fi


CONFIG=$1
PASSWORD=$2
SECRET=$3

if [[ "$3" == "--with-vpnslice=false" ]]; then
    WITH_VPNSLICE=false
fi


setup_help() {
    err "$CONFIG should exist and contain files: [username, host and slice]."
    err "Run setup.sh"
    exit 2;
}

[ ! -d $CONFIG ] && setup_help

config_files=($CONFIG/username $CONFIG/host $CONFIG/slice)
for f in username host slice; do
    if [ ! -f $CONFIG/$f ]; then
	setup_help
    fi
done


USERNAME=$(head -n 1 "$CONFIG/username")
HOST=$(head -n 1 "$CONFIG/host")
SLICES=$(cat "$CONFIG/slice" | tr '\n' ' ')
SERVERCERT=$(test -f "$CONFIG/servercert" && cat "$CONFIG/servercert")


info -------------------------
info OPENCONNECT: $OPENCONNECT
info VPN-SLICE: $VPNSLICE
info USERNAME: $USERNAME
info HOST: $HOST
info SERVERCERT: $SERVERCERT
info -------------------------


info "Kicking off keep-alive pinger."
PINGHOSTS=$CONFIG/pinghosts

BGPID=
if [ -f $PINGHOSTS ]; then
    $DIR/vpn-keepalive.sh $PINGHOSTS &
fi


info "Running openconnect as sudo..."

if [ ! -z "$SERVERCERT" ]; then
    SERVERCERT="--servercert $SERVERCERT"
fi


VPNC_SCRIPT=
if [[ $WITH_VPNSLICE == "true" ]]; then
    VPNC_SCRIPT=" -s '${VPNSLICE} ${SLICES}' "
fi


sudo sh <<EOF
printf '${PASSWORD}' | $OPENCONNECT $SERVERCERT --libproxy --passwd-on-stdin --user='$USERNAME' $VPNC_SCRIPT $HOST
echo "Shutting down"
EOF

if [ -f $PINGHOSTS ]; then
    echo "Killing keep alive $BGPID"
    BPID=$(ps S | grep '[v]pn-keepalive.sh' | awk '{print $1}')
    kill -9 $BPID
fi

echo "Done"
