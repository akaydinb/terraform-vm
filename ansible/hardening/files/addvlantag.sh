#!/bin/bash

# Inserts VLAN definition for given interface -- 21.10.24

if [[ "x$1" == 'x' ]]; then
        # Int. IP given as parameter
        exit 1;
fi

CLIFILE=/etc/netplan/50-cloud-init.yaml
INTNAME=$(grep -B 2 $1 $CLIFILE | head -n 1 | awk '{$1=$1};1' | sed -e 's/[[:punct:]]//')
# remove trailing spaces and non-ascii chars

if [[ "x$INTNAME" == 'x' ]]; then
        echo "Given IP is not found on any interface"
        exit 2
fi

if  grep -q "$INTNAME.150" $CLIFILE; then
    echo "VLAN definition already exists"
else
    cat >> $CLIFILE << POFF
    vlans:
        $INTNAME.150:
            id: 150
            link: $INTNAME
POFF
fi
