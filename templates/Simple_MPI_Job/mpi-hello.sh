#PBS -N my_job
#PBS -l walltime=0:10:00
#PBS -l nodes=4:ppn=12
#PBS -j oe

cp $PBS_O_WORKDIR/* $TMPDIR
cd $TMPDIR

mpicc -O2 mpi-hello.c -o mpi-hello

mpiexec ./mpi-hello

cp $TMPDIR/* $PBS_O_WORKDIR
