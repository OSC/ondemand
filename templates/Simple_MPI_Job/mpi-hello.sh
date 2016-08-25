#PBS -N my_job
#PBS -l walltime=0:10:00
#PBS -l nodes=4:ppn=12
#PBS -j oe

cd $PBS_O_WORKDIR

mpicc -O2 mpi-hello.c -o mpi-hello

cp $PBS_O_WORKDIR/* $PFSDIR
cd $PFSDIR

mpiexec ./mpi-hello

cp $PFSDIR/* $PBS_O_WORKDIR
