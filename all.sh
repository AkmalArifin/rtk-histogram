#!/bin/bash
# Akmal <makmalarifin25@gmail.com>
# Process raw experimental data from fio into a graph in one shot

# resolve the correct absolute path
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    TOPDIR="$( cd -P "$(dirname "$SOURCE" )" && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$TOPDIR/$SOURCE"
done

TOPDIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
RAWDIR=$TOPDIR/raw
DATDIR=$TOPDIR/dat
PLOTDIR=$TOPDIR/plot
EPSDIR=$TOPDIR/eps
SCRIPTDIR=$TOPDIR/script

# Set TARGET to the experiment folder (the subfolder under raw/)
TARGET=$1

# Supported type of GRAPH:
# line : line graph
# hist : histogram
GRAPH=$2

# Supported type of DATA:
# LINE
# -- lat-time   : Latency (Y-axis) vs Time (X-axis)
# -- iops-time  : IOPS (Y-axis) vs Time (X-axis)
# -- bw-time    : Bandwidth (Y-axis) vs Time (X-axis)
# -- lat-cdf    : Latency CDF graph
# HIST
# -- iops-numjobs   : IOPS (Y-axis) vs Numjobs (X-axis)
# -- lat-numjobs    : Latency (Y-axis) vs Numjobs (X-axis)
# -- lat-ratio      : Latency (Y-axis) vs Hit Ratio (X-axis)
DATA=$3

if [[ $# != 3 ]]; then
    echo "Usage: please read comment in all.sh"
    exit 1
fi

# generate dat file from raw
$SCRIPTDIR/raw2dat.sh $TARGET $GRAPH $DATA

# generate plot file from dat
$SCRIPTDIR/genplot.sh $TARGET $GRAPH $DATA

# plot the graph
gnuplot $PLOTDIR/${TARGET}_${DATA}.plot

# open graph
open $EPSDIR/${TARGET}_${DATA}.pdf