#PBS -N parallel_OpenFOAM
#PBS -l nodes=2:ppn=8
#PBS -l walltime=6:00:00
#PBS -j oe
#PBS -S /bin/bash 

#   A Basic OpenFOAM Parallel Job for the OSC Oakley Cluster
#   https://www.osc.edu/supercomputing/software/openfoam

# Initialize OpenFOAM on Oakley Cluster
# This only works if you are using default modules
module load openfoam
#Move to the case directory, where the 0, constant and system directories reside
cd $PBS_O_WORKDIR
#Mesh the geometry
blockMesh
#Decompose the mesh for parallel run
decomposePar
#Run the solver
mpiexec simpleFoam -parallel 
#Reconstruct the parallel results
reconstructPar