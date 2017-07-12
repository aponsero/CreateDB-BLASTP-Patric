#!/bin/bash

#PBS -W group_list=yourlist
#PBS -q standard
#PBS -l select=1:ncpus=3:mem=10gb
#PBS -l walltime=48:00:00
#PBS -l cput=48:00:00
#PBS -M yourmail@email.arizona.edu
#PBS -m bea

LOG="$STDOUT_DIR/create_DB.log"
ERRORLOG="$STDERR_DIR/error.log"

touch $LOG

echo "Started `date`">"$LOG"

echo "Host `hostname`">"$LOG"

cd "$SPLIT_DIR"

export DB_FILE="$DB_DIR/MyDB.faa"
touch $DB_FILE

export FIG_LOG="$DB_DIR/figFam_log"
touch $FIG_LOG

#
# make the MyDB.faa containing the figFam annotated cds from the genomes, without hypothetical proteins and viral cds
#

module load perl

RUN="$WORKER_DIR/concat_wo_viral.pl"
perl $RUN $GENOME_LIST $DB_FILE $FIG_LOG 2> "$ERRORLOG"
 
#
# remove similar sequences with cd-hit
#
export CLUSTER="$DB_DIR/c90_MyDB.faa" 
export RUN="$CD_HIT -i $DB_FILE -o db90 -c 0.9 -M 10000"
$RUN

#
# create the BLAST DB 
#

module load blast
makeblastdb -in $CLUSTER -parse_seqids -dbtype prot

echo "Finished `date`">"$LOG"
