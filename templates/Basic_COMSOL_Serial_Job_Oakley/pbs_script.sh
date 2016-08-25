#PBS -N COMSOL
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=1
#PBS -j oe
#PBS -l software=comsolscript

#   A Basic COMSOL Serial Job for the OSC Oakley Cluster
#   https://www.osc.edu/supercomputing/software/comsol

#
# The following lines set up the COMSOL environment
#
module load comsol
#
# Move to the directory where the job was submitted
#
cd $PBS_O_WORKDIR
cp *.m $TMPDIR
cd $TMPDIR
#
# Run COMSOL
#
comsol batch mycomsol
#
# Now, copy data (or move) back once the simulation has completed
#
cp * $PBS_O_WORKDIR