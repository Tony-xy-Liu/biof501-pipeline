#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

case $1 in
    run)
        export SMK_INPUT_DIR=$2
        snakemake -s main.smk -c12 -d $SCRIPT_DIR/workspace --keep-incomplete
    ;;
    spades)
        singularity run lib/spades.sif spades.py ${*: 2:99}
    ;;
    maxbin2)
        singularity run lib/maxbin2 run_MaxBin.pl ${*: 2:99}
    ;;
    diamond)
        lib/diamond ${*: 2:99}
    ;;
    clear-workspace)
        rm -rf ./workspace/*
    ;;
    *)
        echo "unknown option: [$1]"
    ;;
esac
