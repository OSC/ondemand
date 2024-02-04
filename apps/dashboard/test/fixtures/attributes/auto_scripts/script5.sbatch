#!/bin/bash
#SBATCH --job-name=hello_world_test # Job name
#SBATCH --ntasks=1                  # Run a single task
#SBATCH --mem=1gb                   # Job Memory
#SBATCH --time=01:00:00             # Time limit hrs:min:sec
echo 'Hello World'