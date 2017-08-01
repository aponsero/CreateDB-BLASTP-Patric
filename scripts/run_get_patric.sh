#!/bin/bash

#PBS -l select=1:ncpus=1:mem=4gb
#PBS -l walltime=2:00:00
#PBS -l cput=2:00:00
#PBS -l place=pack:shared

HOST=`hostname`
LOG="$STDOUT_DIR/$HOST_getPatric_.log"
ERRORLOG="$STDERR_DIR/$HOST_error.log"

echo "Started `date`">>"$LOG"

echo "Host `hostname`">>"$LOG"

cd "$SPLIT_DIR"

FILE="$SPLIT_DIR/xaa"

echo "working on File \"$FILE\"" >>"$LOG"

#
# Go through each of the Genomes ID in the XFILE and FTP download the ffn, faa 
#

DIR="$FILE.dir"
if [[ ! -d $DIR ]]; then
    mkdir -p $DIR
fi

cd $DIR
RUN="$WORKER_DIR/download_patric.pl"
perl $RUN $FILE 2>"$ERRORLOG"

echo "Finished `date`">>"$LOG"
