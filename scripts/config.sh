export CWD=$PWD
# where programs are
export BIN_DIR="/rsgrps/bhurwitz/hurwitzlab/bin"
export CD_HIT="/rsgrps/bhurwitz/alise/tools/cdhit/cd-hit"
# genomes configs
export SPLIT_SIZE=300
export GENOME_LIST="YOUR/PATH/HERE"
export SPLIT_DIR="YOUR/PATH/HERE"
export DB_DIR="YOUR/PATH/HERE"
# scripts configs
export SCRIPT_DIR="$PWD/scripts"
export WORKER_DIR="$SCRIPT_DIR/workers"
export CD_SIM="0.9"
# user info
export MAIL_USER="youremail@email.arizona.edu"
export MAIL_TYPE="bea"
export GROUP="yourgroup"
export QUEUE="windfall"


#
# --------------------------------------------------
function init_dir {
    for dir in $*; do
        if [ -d "$dir" ]; then
            rm -rf $dir/*
        else
            mkdir -p "$dir"
        fi
    done
}

# --------------------------------------------------
function lc() {
    wc -l $1 | cut -d ' ' -f 1
}
