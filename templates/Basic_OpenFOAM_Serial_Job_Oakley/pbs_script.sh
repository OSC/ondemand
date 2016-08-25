#PBS -N serial_OpenFOAM 
#PBS -l nodes=1:ppn=1 
#PBS -l walltime=24:00:00 
#PBS -j oe 
#PBS -S /bin/bash 

#  A Basic OpenFOAM Serial Job for the OSC Oakley Cluster
#  https://www.osc.edu/supercomputing/software/openfoam

# Initialize OpenFOAM on Oakley Cluster
# This only works if you are using default modules
module load openfoam
# Move to the case directory, where the 0, constant and system directories reside
cd $PBS_O_WORKDIR
# Copy files to $TMPDIR and move there to execute the program
cp * $TMPDIR
cd $TMPDIR
# Mesh the geometry
blockMesh
# Run the solver
icoFoam
# Finally, copy files back to your home directory
cp * $PBS_O_WORKDIR