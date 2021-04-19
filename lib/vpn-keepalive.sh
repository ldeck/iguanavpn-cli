#!/usr/bin/env bash

PINGHOSTS=$1
INTERVAL=${2:-60}



while [ 1 ]; do
    sleep $INTERVAL;
    while read host; do
        ping -c 2 $host | sed -e 's/^/[vpn keep alive] /';
    done < $PINGHOSTS
done
