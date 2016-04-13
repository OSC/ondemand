#PBS -N my_job
#PBS -l walltime=0:10:00
#PBS -l nodes=1:ppn=12
#PBS -j oe

cd $PBS_O_WORKDIR
icc -O2 -openmp omp-hello.c -o omp-hello
export OMP_NUM_THREADS=12
./omp-hello
