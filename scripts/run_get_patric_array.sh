#!/bin/bash

#PBS -l select=3:ncpus=2:mem=4gb
#PBS -l pvmem=235gb
#PBS -l walltime=2:00:00
#PBS -l cput=6:00:00
#PBS -l place=pack:shared

HOST=`hostname`
LOG="$STDOUT_DIR/$HOST_getPatric_.log"
ERRORLOG="$STDERR_DIR/$HOST_error.log"

echo "Started `date`">>"$LOG"

echo "Host `hostname`">>"$LOG"

cd "$SPLIT_DIR"

XFILE=`head -n +${PBS_ARRAY_INDEX} $SPLIT_LIST | tail -n 1`
CFILE=${XFILE:2}
FILE="$SPLIT_DIR/$CFILE"

echo "working on File \"$FILE\"" >>"$LOG"

#
# Go through each of the Genomes ID in the XFILE and FTP download the ffn, faa 
#

DIR="$FILE.dir"
if [[ ! -d $DIR ]]; then
    mkdir -p $DIR
fi

cd $DIR
RUN="$SCRIPT_DIR/workers/download_patric.pl"
perl $RUN $FILE 2>"$ERRORLOG"

echo "Finished `date`">>"$LOG"
