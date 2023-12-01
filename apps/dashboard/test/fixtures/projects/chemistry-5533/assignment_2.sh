#!/bin/bash

#SBATCH --tasks-per-node 4

INPUT_FILE=$PWD/input_data/assignment_1.inp
OUTPUT_DIR=$PWD/output_data

module load intel
module load mvapich2
module load qchem

set -x

# copy input file to $TMPDIR
cp $INPUT_FILE $TMPDIR/assignment_2.inp
cd $TMPDIR
INPUT_FILE="$TMPDIR/assignment_2.inp"

qchem -np $SLURM_NPROCS $INPUT_FILE
ls -lrta
cp assignment_2.fchk $OUTPUT_DIR
