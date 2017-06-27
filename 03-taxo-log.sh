#
# This script is intended to create a taxonomic log and a FigFam translation log
#

source ./config.sh

PROG="03-taxo_log"
export STDERR_DIR="$SCRIPT_DIR/err/$PROG"
export STDOUT_DIR="$SCRIPT_DIR/out/$PROG"


init_dir "$STDERR_DIR" "$STDOUT_DIR" 

cd "$SPLIT_DIR"


export TAXDIR="$SPLIT_DIR/taxonomy"
init_dir "$TAXDIR"

export GENOME_LIST="$DB_DIR/genomes_log"


    JOB_ID=`qsub -v WORKER_DIR,DB_DIR,SPLIT_DIR,GENOME_LIST,TAXDIR,STDERR_DIR,STDOUT_DIR -N create_taxolog -e "$STDERR_DIR" -o "$STDOUT_DIR" $WORKER_DIR/run_taxo_log.sh`

if [ "${JOB_ID}x" != "x" ]; then
        echo Job: \"$JOB_ID\"
    else
        echo Problem submitting job.
    fi
