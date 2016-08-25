#PBS -N knee
#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=1
#PBS -l software=abaqus+5
#PBS -j oe
#
# The following lines set up the ABAQUS environment
# Further Details at
#	https://www.osc.edu/supercomputing/software/abaqus
#
module load abaqus
#
# Move to the directory where the job was submitted
#
cd $PBS_O_WORKDIR
cp *.inp $TMPDIR
cd $TMPDIR
#
# Run ABAQUS
#
abaqus job=knee_bolster interactive
#
# Now, copy data (or move) back once the simulation has completed
#
cp * $PBS_O_WORKDIR