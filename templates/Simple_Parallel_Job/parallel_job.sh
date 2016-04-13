#PBS -N my_job
#PBS -l walltime=00:20:00
#PBS -l nodes=4:ppn=12
#PBS -j oe
module swap intel gnu
mpiexec <user_executable>

