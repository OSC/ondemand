#PBS -N star-ccm_test  
#PBS -l walltime=10:00:00  
#PBS -l nodes=1:ppn=1  
#PBS -l software=starccm+1
#PBS -j oe
#PBS -S /bin/bash

#   A Basic Star-CCM+ Serial Job for the OSC Oakley Cluster
#   https://www.osc.edu/supercomputing/software/star_ccm

cd $TMPDIR  

cp $PBS_O_WORKDIR/starccm.sim . 

module load starccm  

starccm+ -batch starccm.sim >&output.txt  

cp output.txt $PBS_O_WORKDIR
