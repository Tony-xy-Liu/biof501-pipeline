#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

case $1 in
    run)
        export SMK_INPUT=$2
        snakemake -s main.smk -c12 --keep-incomplete
    ;;
    checkm)
        singularity run lib/checkm.sif checkm.py ${*: 2:99}
    ;;
    prodigal)
        singularity run lib/prodigal.sif run_MaxBin.pl ${*: 2:99}
    ;;
    concoct)
        singularity run lib/concoct.sif run_MaxBin.pl ${*: 2:99}
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
