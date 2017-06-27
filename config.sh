export CWD=$PWD
# where programs are
export BIN_DIR="/rsgrps/bhurwitz/hurwitzlab/bin"
export CD_HIT="/rsgrps/bhurwitz/alise/tools/cdhit/cd-hit"
# genomes configs
export SPLIT_SIZE=300
export GENOME_LIST="/rsgrps/bhurwitz/hurwitzlab/data/patric/genomes/soil_Patric"
export SPLIT_DIR="/rsgrps/bhurwitz/hurwitzlab/data/patric/genomes/soil_download"
export DB_DIR="/rsgrps/bhurwitz/hurwitzlab/data/patric/genomes/soil_BLASTP_DB"
# scripts configs
export SCRIPT_DIR=$PWD
export WORKER_DIR="$SCRIPT_DIR/workers"

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
