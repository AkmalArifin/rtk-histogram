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

if [[ $GRAPH == "line" ]]; then
    echo "LINE"

    i=1
    LIST_TARGET=($1)
    input=" "

    while [[ $input != "" ]]; do
        read input
        LIST_TARGET[$i]=$input
        i+=1
    done
    for value in "${LIST_TARGET[@]}"; do
        if [[ $value != "" ]]; then
            python $SCRIPTDIR/line.py $value $GRAPH $DATA $TARGET
        fi
    done
elif [[ $GRAPH == "hist" ]]; then
    echo "HIST"

    i=1
    LIST_TARGET=($1)
    input=" "

    while [[ $input != "" ]]; do
        read input
        LIST_TARGET[$i]=$input
        i+=1
    done
    for value in "${LIST_TARGET[@]}"; do # Ini per file
        if [[ $value != "" ]]; then
            python $SCRIPTDIR/histogram.py $value $GRAPH $DATA $TARGET
        fi
    done

    if [[ $DATA == "lat-ratio" ]]; then
        FOLDER_PATH="$DATDIR"/"$TARGET"
        for file in "$FOLDER_PATH"/*; do
            if [ -f "$file" ] && [ $file != "$FOLDER_PATH"/"$TARGET".dat ]; then
                # echo $file
                cat $file >> "$FOLDER_PATH"/"$TARGET".dat
            fi
        done
    fi

fi

# for value in "${LIST_TARGET[@]}"; do
#     if [[ $value != "" ]]; then
#         if [[ $GRAPH == "line" ]]; then
#             echo "LINE" 
#             python $SCRIPTDIR/line.py $value $GRAPH $DATA $TARGET
#         elif [[ $GRAPH == "hist" ]]; then
#             echo "HITS"
#             python $SCRIPTDIR/histogram.py $value $GRAPH $DATA $TARGET
#         fi
#     fi
# done