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

if [[ $# -ne 3 ]]; then
    err "Usage: $0 <config> <password> <secret>";
    exit 1;
fi


CONFIG=$1
PASSWORD=$2
SECRET=$3


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
info SLICES: $SLICES
info SERVERCERT: $SERVERCERT
info -------------------------


info "Kicking off keep-alive pinger."
PINGHOSTS=$CONFIG/pinghosts

BGPID=
if [ -f $PINGHOSTS ]; then
    $DIR/vpn-keepalive.sh $PINGHOSTS &
    BGPID=$!
fi


info "Running openconnect as sudo..."

if [ ! -z "$SERVERCERT" ]; then
    SERVERCERT="--servercert $SERVERCERT"
fi


sudo sh <<EOF
printf '${PASSWORD}\n${SECRET}' | $OPENCONNECT $SERVERCERT --passwd-on-stdin --user='$USERNAME' -s '${VPNSLICE} ${SLICES}' $HOST
echo "Shutting down"
EOF

if [ ! -z BGPID ]; then
    echo "Killing keep alive $BGPID"
    kill $BGPID
fi

echo "Done"
