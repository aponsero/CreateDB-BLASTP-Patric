#
# This script is intended to create a Database file containing the bacterial CDS --> output "MyDB.faa"
#

source ./config.sh

PROG="02-CreateDB"
export STDERR_DIR="$SCRIPT_DIR/err/$PROG"
export STDOUT_DIR="$SCRIPT_DIR/out/$PROG"


init_dir "$STDERR_DIR" "$STDOUT_DIR" "$DB_DIR"

cd "$SPLIT_DIR"

export FILES_LIST="split-files"

NUM_FILES=$(lc $FILES_LIST)

echo Found \"$NUM_FILES\" files in \"$SPLIT_DIR\"


export GENOME_LIST="$DB_DIR/genomes_log"
touch $GENOME_LIST

cat $FILES_LIST | while read XFILE ; do
        CFILE=${XFILE:2}

        export FILE="$SPLIT_DIR/$CFILE"
	
	cat $FILE | while read GENOME ; do
		echo "$FILE.dir/$GENOME">>"$GENOME_LIST"	
	done
done

if [ $NUM_FILES -gt 0 ]; then
    JOB_ID=`qsub -v WORKER_DIR,SPLIT_DIR,FILES_LIST,STDERR_DIR,STDOUT_DIR,GENOME_LIST,CD_HIT,DB_DIR -N create_DB -e "$STDERR_DIR" -o "$STDOUT_DIR" $WORKER_DIR/run_create_DB.sh`

if [ "${JOB_ID}x" != "x" ]; then
        echo Job: \"$JOB_ID\"
    else
        echo Problem submitting job.
    fi
else
    echo Nothing to do.
fi
