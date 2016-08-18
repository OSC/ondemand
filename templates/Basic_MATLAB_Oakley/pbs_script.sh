#PBS -N matlab_example
#PBS -l walltime=00:10:00
#PBS -l nodes=1:ppn=12
#PBS -j oe

#   A Basic MATLAB Job for the OSC Oakley Cluster
#   https://www.osc.edu/supercomputing/software/matlab

module load matlab
matlab -nodisplay -nodesktop < hello.m
# end of example file