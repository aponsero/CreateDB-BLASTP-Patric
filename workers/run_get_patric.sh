#!/bin/bash

#PBS -W group_list=yourlist
#PBS -q standard
#PBS -l select=3:ncpus=2:mem=4gb
#PBS -l pvmem=235gb
#PBS -l walltime=2:00:00
#PBS -l cput=6:00:00
#PBS -M yourmail@email.arizona.edu
#PBS -m bea

LOG="$STDOUT_DIR/getPatric.log"
ERRORLOG="$STDERR_DIR/error.log"

if [ ! -f "$LOG" ] ; then
	touch "$LOG"
fi

echo "Started `date`">>"$LOG"

echo "Host `hostname`">>"$LOG"

cd "$SPLIT_DIR"

XFILE=`head -n +${PBS_ARRAY_INDEX} $FILES_LIST | tail -n 1`
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
