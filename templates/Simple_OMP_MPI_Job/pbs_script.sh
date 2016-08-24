#PBS -N my_job
#PBS -l walltime=20:00:00
#PBS -l nodes=4:ppn=12
#PBS -j oe

# This example is a hybrid MPI/OpenMP job. It runs one MPI process per node with 12 threads per process.
# The assumption here is that the code was written to support multilevel parallelism.
# The executable is named hybridprogram.
#   https://www.osc.edu/supercomputing/batch-processing-at-osc/job-scripts

export OMP_NUM_THREADS=12
export MV2_ENABLE_AFFINITY=0

cd $PBS_O_WORKDIR

pbsdcp hybridprogram $TMPDIR

cd $TMPDIR

mpiexec -ppn 1 hybridprogram

pbsdcp -g 'results*' $PBS_O_WORKDIR
