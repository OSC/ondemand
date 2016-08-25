#PBS -N my_job
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=12
#PBS -j oe

# This example uses 1 node with 12 cores, which is suitable for Oakley. A similar job on Glenn would use 8 cores;
# the OMP_NUM_THREADS environment variable would also be set to 8. A program must be written to take advantage
# of multithreading for this to work.
#   https://www.osc.edu/supercomputing/batch-processing-at-osc/job-scripts

cp $PBS_O_WORKDIR/* $TMPDIR
cd $TMPDIR
export OMP_NUM_THREADS=12
icc -O2 -openmp omp-hello.c -o omp-hello
./omp-hello > my_results
cp my_results $PBS_O_WORKDIR
