#!/bin/bash
#
#SBATCH --job-name=test
#SBATCH --output=res.txt
#
#SBATCH --ntasks=1
#SBATCH --time=10:00
#SBATCH --mem-per-cpu=100

cd $SLURM_SUBMIT_DIR
echo "Hello World" > output_file

echo "Created output file with 'Hello World'"
