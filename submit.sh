#!/bin/sh
set -u
#
# Checking args
#

source scripts/config.sh

if [[ ! -f "$GENOME_LIST" ]]; then
    echo "$FGENOME_LIST does not exist. Please provide a list of ID to process Job terminated."
    exit 1
fi

if [[ ! "$GENOME_LIST" ]]; then
    echo "$FGENOME_LIST does not exist. Please provide a list of ID to process Job terminated."
    exit 1
fi

if [[ ${#CD_SIM} -lt 1 ]]; then
  echo "Incorrect similarity value for CD_SIM parameter. Please correct specified parameter in config file. Job terminated."
  exit 1
fi

if [[ ! -d "$SCRIPT_DIR" ]]; then
    echo "$SCRIPT_DIR does not exist. Job terminated."
    exit 1
fi

if [[ ! -d "$SPLIT_DIR" ]]; then
    echo "$SPLIT_DIR does not exist. Directory created for database genomes download."
    mkdir -p "$SPLIT_DIR"
fi

if [[ ! -d "$DB_DIR" ]]; then
    echo "$DB_DIR does not exist. Directory created for database output"
    mkdir -p "$DB_DIR"
fi

#
# Job submission
#

PREV_JOB_ID=""
ARGS="-q $QUEUE -W group_list=$GROUP -M $MAIL_USER -m $MAIL_TYPE"

#
## 01-download Patric
#

PROG="01-downloadPatric"
export STDERR_DIR="$SCRIPT_DIR/err/$PROG"
export STDOUT_DIR="$SCRIPT_DIR/out/$PROG"

init_dir "$STDERR_DIR" "$STDOUT_DIR"

echo "working on $GENOME_LIST"
export NUM_GENOMES=$(lc $GENOME_LIST)
echo "$NUM_GENOMES id found"

if [ $NUM_GENOMES -gt 0 ]; then
        LOG="$STDOUT_DIR/split.log"
        ERRORLOG="$STDERR_DIR/error.log"
        touch $LOG
        echo "Started `date`">"$LOG"
        echo "Host `hostname`">"$LOG"

# Sort the genomes by numerical order --> output in "sorted" file

        cd "$SPLIT_DIR"
        mapfile -t TEMP_ARRAY < $GENOME_LIST
        export SORTED="sorted"
        touch $SORTED
        sort -n < (printf "%s\n" "${TEMP_ARRAY[@]}") >"$SORTED"

# Split the sorted genome list into Xfiles

        split --lines=$SPLIT_SIZE $SORTED
       
# delete sorted list

        rm $SORTED

        export SPLIT_LIST="split-files"

        find . -type f -name x\* > $SPLIT_LIST

        export NUM_FILES=$(lc $SPLIT_LIST)

        echo Found \"$NUM_FILES\" files in \"$SPLIT_DIR\"

        if [ $NUM_FILES -gt 1 ]; then  
             echo "launching $SCRIPT_DIR/run_get_patric.sh as array job."

             JOB_ID=`qsub $ARGS -v WORKER_DIR,SPLIT_DIR,SPLIT_LIST,NUM_FILES,STDERR_DIR,STDOUT_DIR -N get-patric -e "$STDERR_DIR" -o "$STDOUT_DIR" -J 1-$NUM_FILES $SCRIPT_DIR/run_get_patric_array.sh`
    
             if [ "${JOB_ID}x" != "x" ]; then
                echo Job: \"$JOB_ID\"
                PREV_JOB_ID=$JOB_ID
             else
                echo Problem submitting job. Job terminated.
                exit 1
             fi

       else 
              echo "launching $SCRIPT_DIR/run_get_patric.sh as unique job."
              
              JOB_ID=`qsub $ARGS -v WORKER_DIR,SPLIT_DIR,NUM_FILES,STDERR_DIR,STDOUT_DIR -N get-patric -e "$STDERR_DIR" -o "$STDOUT_DIR" $SCRIPT_DIR/run_get_patric.sh`

             if [ "${JOB_ID}x" != "x" ]; then
                echo Job: \"$JOB_ID\"
                PREV_JOB_ID=$JOB_ID
             else
                echo Problem submitting job. Job terminated.
                exit 1
             fi
       fi
else
    echo Empty id list provided. Nothing to do. Job terminated
    exit 1
fi

#
## 02- create DB
#


PROG2="02-CreateDB"
export STDERR_DIR2="$SCRIPT_DIR/err/$PROG2"
export STDOUT_DIR2="$SCRIPT_DIR/out/$PROG2"


init_dir "$STDERR_DIR2" "$STDOUT_DIR2"

echo " launching $SCRIPT_DIR/run_create_DB.sh in queue"
echo "previous job ID $PREV_JOB_ID"

JOB_ID=`qsub $ARGS -v WORKER_DIR,SPLIT_DIR,SPLIT_LIST,STDERR_DIR2,STDOUT_DIR2,CD_HIT,CD_SIM,DB_DIR -N create_DB -e "$STDERR_DIR" -o "$STDOUT_DIR" -W depend=afterok:$PREV_JOB_ID $SCRIPT_DIR/run_create_DB.sh`

if [ "${JOB_ID}x" != "x" ]; then
        echo Job: \"$JOB_ID\"
        PREV_JOB_ID=$JOB_ID
else
        echo Problem submitting job. Job terminated.
        exit 1
fi
 

#
## 03- create taxo
#

PROG3="03-taxo_log"
export STDERR_DIR3="$SCRIPT_DIR/err/$PROG3"
export STDOUT_DIR3="$SCRIPT_DIR/out/$PROG3"


init_dir "$STDERR_DIR3" "$STDOUT_DIR3"

cd "$SPLIT_DIR"


export TAXDIR="$SPLIT_DIR/taxonomy"
init_dir "$TAXDIR"

export DOWNLOAD_LIST="$DB_DIR/genomes_log"

JOB_ID=`qsub $ARGS-v WORKER_DIR,DB_DIR,SPLIT_DIR,DOWNLOAD_LIST,TAXDIR,STDERR_DIR3,STDOUT_DIR3 -N create_taxolog -e "$STDERR_DIR" -o "$STDOUT_DIR" -W "depend=afterok:$PREV_JOB_ID" $SCRIPT_DIR/run_taxo_log.sh`

if [ "${JOB_ID}x" != "x" ]; then
        echo Job: \"$JOB_ID\"
else
        echo Problem submitting job. Job terminated.
        exit 1
fi

echo "job successfully submited"
