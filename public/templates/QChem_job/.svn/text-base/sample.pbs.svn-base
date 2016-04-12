#PBS -N sample_qchem_job
#PBS -l walltime=0:59:00
#PBS -S /bin/csh
#PBS -j oe
#PBS -l nodes=1:ppn=1
#
# This is a sample script for running a basic Q-Chem job.
# The only thing you need to modify is 'sample' here:
#
setenv JOBNAME sample
#
# replacing 'sample' with the actual name of your input file.
#
module load qchem
cd $PBS_O_WORKDIR
#
# save input files:
#qchem -save $NAME.inp $NAME.out $NAME
# do not save input files:
qchem $JOBNAME.inp $JOBNAME.out 

