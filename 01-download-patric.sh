#
# This script is intended to download all patric data for all genomes in split files 
#

source ./config.sh

PROG="01-downloadPatric"
export STDERR_DIR="$SCRIPT_DIR/err/$PROG"
export STDOUT_DIR="$SCRIPT_DIR/out/$PROG"

init_dir "$STDERR_DIR" "$STDOUT_DIR" "$SPLIT_DIR"
export FILES_LIST="$GENOME_LIST"
echo "working on $GENOME_LIST"
export NUM_GENOMES=$(lc $FILES_LIST)
echo "$NUM_GENOMES id found"

if [ $NUM_GENOMES -gt 0 ]; then
        LOG="$STDOUT_DIR/split.log"
        ERRORLOG="$STDERR_DIR/error.log"
        touch $LOG
        echo "Started `date`">"$LOG"
        echo "Host `hostname`">"$LOG"

#
# Sort the genomes by numerical order --> output in "sorted" file
#

        cd "$SPLIT_DIR"
        mapfile -t TEMP_ARRAY < $FILES_LIST
        export SORTED="sorted"
        touch $SORTED
        sort -n <(printf "%s\n" "${TEMP_ARRAY[@]}") >"$SORTED"
#
# Split the sorted genome list into Xfiles
#

        split --lines=$SPLIT_SIZE $SORTED
        echo "Finished `date`">"$LOG"
#
# delete sorted list
#

        rm $SORTED

	cd "$SPLIT_DIR"

	export FILES_LIST="split-files"

	find . -type f -name x\* > $FILES_LIST

	export NUM_FILES=$(lc $FILES_LIST)

	echo Found \"$NUM_FILES\" files in \"$SPLIT_DIR\"

	if [ $NUM_FILES -gt 0 ]; then
    		JOB_ID=`qsub -v WORKER_DIR,SPLIT_DIR,FILES_LIST,NUM_FILES,STDERR_DIR,STDOUT_DIR -N get-patric -e "$STDERR_DIR" -o "$STDOUT_DIR" -J 1-$NUM_FILES $WORKER_DIR/run_get_patric.sh`

    	if [ "${JOB_ID}x" != "x" ]; then
        	echo Job: \"$JOB_ID\"
    	else
        	echo Problem submitting job.
    	fi
	else
    	echo Nothing to do.
	fi


else
    echo Nothing to do.
fi

