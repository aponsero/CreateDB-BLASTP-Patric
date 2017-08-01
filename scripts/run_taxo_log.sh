#!/bin/bash

#PBS -l select=1:ncpus=1:mem=10gb
#PBS -l walltime=08:00:00
#PBS -l cput=08:00:00
#PBS -l place=pack:shared

LOG="$STDOUT_DIR3/tax.log"
ERRORLOG="$STDERR_DIR3/error.log"

touch $LOG

echo "Started `date`">"$LOG"

echo "Host `hostname`">"$LOG"

cd "$SPLIT_DIR"

export TAXO="$DB_DIR/taxo_log"
touch $TAXO

module load perl

RUN="$WORKER_DIR/create_tax_log.pl"
perl $RUN $DOWNLOAD_LIST $TAXO $TAXDIR		

echo "Finished `date`">"$LOG"
