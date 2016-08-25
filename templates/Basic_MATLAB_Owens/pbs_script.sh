#PBS -N disable_multithreading
#PBS -l walltime=00:10:00
#PBS -l nodes=1:ppn=28
#PBS -j oe

#  A Basic MATLAB Job for the OSC Owens Cluster
#  https://www.osc.edu/supercomputing/software/matlab

module load matlab
matlab -singleCompThread -nodisplay -nodesktop < hello.m
# end of example file
