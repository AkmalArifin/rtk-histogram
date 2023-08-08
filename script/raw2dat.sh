#!/bin/bash
# Akmal <makmalarifin25@gmail.com>
#
# Generate a template gnuplot file
#
# TODO: handle other type of data


SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    TOPDIR="$( cd -P "$(dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$TOPDIR/$SOURCE"
done

TOPDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )/.."
RAWDIR=$TOPDIR/raw
DATDIR=$TOPDIR/dat
PLOTDIR=$TOPDIR/plot
EPSDIR=$TOPDIR/eps
SCRIPTDIR=$TOPDIR/script

##############################################################################

PYTHON=$(which python)
if [[ ! -x "$PYTHON" ]]; then
    echo "You need python installed to generate graphs"
    exit 1
fi

[[ ! -d $DATDIR ]] && mkdir -p $DATDIR

TARGET="$1"
GRAPH="$2"
DATA="$3"

i=1
LIST_TARGET=($1)
input="temporary"

while [[ $input != "" ]]; do
    read input
    LIST_TARGET[$i]=$input
    i+=1
done

for value in "${LIST_TARGET[@]}"; do
    if [[ $value != "" ]]; then 
        python $SCRIPTDIR/raw2dat.py $value $GRAPH $DATA $TARGET
    fi
done