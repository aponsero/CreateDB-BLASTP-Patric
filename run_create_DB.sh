#!/bin/bash

#PBS -l select=1:ncpus=5:mem=10gb
#PBS -l walltime=48:00:00
#PBS -l cput=48:00:00
#PBS -l place=pack:shared

LOG="$STDOUT_DIR/create_DB.log"
ERRORLOG="$STDERR_DIR/error.log"

touch $LOG

echo "Started `date`">"$LOG"

echo "Host `hostname`">>"$LOG"

cd "$SPLIT_DIR"

export DB_FILE="$DB_DIR/MyDB.faa"
touch $DB_FILE

export FIG_LOG="$DB_DIR/figFam_log"
touch $FIG_LOG

export FILES_LIST="split-files"
export GENOME_LIST="$DB_DIR/genomes_log"
touch $GENOME_LIST

cat $FILES_LIST | while read XFILE ; do
        CFILE=${XFILE:2}

        export FILE="$SPLIT_DIR/$CFILE"

        cat $FILE | while read GENOME ; do
                echo "$FILE.dir/$GENOME">>"$GENOME_LIST"
        done

#
# make the MyDB.faa containing the figFam annotated cds from the genomes, without hypothetical proteins and viral cds
#

module load perl

RUN="$WORKER_DIR/concat_wo_viral.pl"
perl $RUN $GENOME_LIST $DB_FILE $FIG_LOG 2>> "$ERRORLOG"
 
#
# remove similar sequences with cd-hit
#
export CLUSTER="$DB_DIR/c90_MyDB.faa"
export RUN="$CD_HIT -i $DB_FILE -o $CLUSTER -c $CD_SIM -M 10000 -T 5"
$RUN >> "$LOG"

#
# create the BLAST DB 
#

module load blast
makeblastdb -in $CLUSTER -parse_seqids -dbtype prot >> "$LOG"

echo "Finished `date`">>"$LOG"
