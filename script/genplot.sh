#!/bin/bash
# Akmal <makmalarifin25@gmail.com>
#
# Generate a template gnuplot file
#

# TODO: create plot filter it by its extension or create another folder each data

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

GNUPLOT=$(which gnuplot)
if [[ ! -x "$GNUPLOT" ]]; then
    echo "You need gnuplot installed to generate graphs"
    exit 1
fi

[[ ! -d $PLOTDIR ]] && mkdir -p $PLOTDIR

[[ ! -d $EPSDIR ]] && mkdir -p $EPSDIR

TARGET="$1"
GRAPH="$2"
DATA="$3"

STYLE=
XRANGE=
YRANGE=
XLABEL=
YLABEL=
YGRID=
XTICS=
OUTPUT=
KEY=

case $GRAPH in
    "line")
        case $DATA in
            "lat-time")
                TITLE="set title \"Latency vs Time\""
                XRANGE="set xrange [0:]"
                YRANGE="set yrange [0:]"
                XLABEL="set xlabel \"Time (s)\\n\""
                YLABEL="set ylabel \"Latency (ms)\""
                YGRID="set grid ytics lt 2 lc rgb \"gray\" lw 1"
                KEY="set key bmargin center horizontal"
                X="(\$1/1000)"      # timestamp ms -> s, show in seconds
                Y="(\$2*0.000001)"  # latency ns -> ms, show in miliseconds
                # X=1      # timestamp ms -> s, show in seconds
                # Y=2      # latency us -> ms, show in millionseconds
                ;;
            "iops-time")
                TITLE="set title \"IOPS vs Time\""
                XRANGE="set xrange [0:]"
                YRANGE="set yrange [0:]"
                XLABEL="set xlabel \"Time (s)\\n\""
                YLABEL="set ylabel \" KIOPS\""
                KEY="set key bmargin center horizontal"
                X="(\$1/1000)"  # IOPS -> KIOPS, show in kiloiops
                Y="(\$2/1000)" # timestamp ms -> s, show in seconds
                ;;
            "bw-time")
                TITLE="set title \"Bandwidth vs Time\""
                XRANGE="set xrange [0:]"
                YRANGE="set yrange [0:]"
                XLABEL="set xlabel \"Time (s)\\n\""
                YLABEL="set ylabel \"Bandwidth (MB/s)\""
                KEY="set key bmargin center horizontal"
                X="(\$1/1000)"      # timestamp ms -> s, show in seconds
                Y="(\$2*0.001024)"  # bandwidth KiB/s -> MB/s, show in megabyte per second
                ;;
            "lat-cdf")
                TITLE="set title \"Latency CDF\""
                XRANGE="set xrange [0:]"
                YRANGE="set yrange [0:]"
                XLABEL="set xlabel \"Latency (ms)\\n\""
                KEY="set key bmargin center horizontal"
                X="(\$2*0.000001)"      # timestamp ms -> s, show in seconds
                Y=1  # bandwidth KiB/s -> MB/s, show in megabyte per second
                ;;
            *)
                echo "Unknown Type: $TYPE, exiting .."
                exit
                ;;
        esac
        ;;
    "hist")
        case $DATA in
            "iops-numjobs")
                TITLE="set title \"IOPS vs Numjobs\""
                STYLE="set style fill solid border .7"
                XRANGE="set xrange[-1:]"
                YRANGE="set yrange[0:]"
                XLABEL="set xlabel \"Numjobs\\n\""
                YLABEL="set ylabel \"KIOPS\""
                YGRID="set grid ytics lt 2 lc rgb \"gray\" lw 1"
                KEY="set key bmargin center horizontal"
                # XTICS="set xtics 1,2,4,8,16,32,64,128"
                Y="xtic(1)"
                X="(\$2/1000)"
                ;;
            "lat-numjobs")
                TITLE="set title \"Latency vs Numjobs\""
                STYLE="set style fill solid border .7"
                XRANGE="set xrange[-1:]"
                YRANGE="set yrange[0:]"
                XLABEL="set xlabel \"Numjobs\\n\""
                YLABEL="set ylabel \"Latency (ms)\""
                YGRID="set grid ytics lt 2 lc rgb \"gray\" lw 1"
                KEY="set key bmargin center horizontal"
                # XTICS="set xtics 1,2,4,8,16,32,64,128"
                Y="xtic(1)"
                X="(\$2*0.000001)"
                ;;
            *)
                echo "Unknown Type: $TYPE, exiting .."
                exit
                ;;
        esac
        ;;
    *)
        echo "Unknown Type: $TYPE, exiting .."
        exit
        ;;
esac

# TERM="set term postscript eps enhanced color 20"
TERM="set term pdf"
OUTPUT="set output \"eps/${TARGET}_${DATA}.pdf\""
# SIZE="set size 2,1.5"
SIZE="set size 1,1"
PLOT="plot \\"

declare -a rgbcolors=(\"gray\" \"green\" \"blue\" \"magenta\" \"orange\" \
                    \"cyan\" \"yellow\" \"purple\" \"pink\" \"red\")

nbcolors=${#rgbcolors[@]}

function getCI()
{
    local datfname=$1
    echo $(basename $datfname | gawk -F"_" '{print $1}')
}

function getLT()
{
    local rawfname=$1
    echo $(basename $rawfname | gawk -F"_" '{print $2}')
}

# given file name and line titile, get the plot command
# $1: dat file name
# $2: line title, from getLT()
# $3: color index, [0..nbcolors]
# $4: total # of dat files, make sure color red is used for the last file
function plotone()
{
    local datfname=$1
    local LT=$2
    local CI=$3
    local nbdatfiles=$4
    local MAXCI=$(($nbdatfiles - 1))
    if [[ $CI == $MAXCI ]]; then # last will always red
        CI=$(( $nbcolors-1 ))
    elif [[ $CI -gt $nbcolors ]]; then
        CI=$(( $CI % $nbcolors + 1))
    fi
    echo "'$datfname' u $X:$Y t \"$LT\" w ${GRAPH} lc rgb ${rgbcolors[$CI]} lw 2, \\"
}

function genplot()
{
    # we are picky about colors, so be careful about the ordering
    if [[ -e $PLOTDIR/${TARGET}.plot ]]; then
        echo "Found existing plot file: ${TARGET}.plot"
        # exit
    fi

    nbfiles=$(ls -l dat/$TARGET/*.dat | wc -l)

    # write plot file
    {
        echo "${TERM}"
        echo "${TITLE}"
        echo "${OUTPUT}"
        echo "${SIZE}"
        echo "${KEY}"
        echo "${STYLE}"
        echo "${XRANGE}"
        echo "${YRANGE}"
        echo "${XLABEL}"
        echo "${YLABEL}"
        echo "${YGRID}"
        echo "${XTICS}"

        # settings should come before this line
        echo "${PLOT}"
        
        cnt=0
        for i in dat/$TARGET/*.dat; do
            LT=$(getLT $i)
            plotone $i $LT $cnt $nbfiles
            ((cnt += 1))
        done
    } > $PLOTDIR/${TARGET}_${DATA}.plot
}

genplot

echo "==== genplot done ===="
