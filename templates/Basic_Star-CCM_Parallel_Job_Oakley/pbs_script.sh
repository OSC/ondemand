#PBS -N starccm_test 
#PBS -l walltime=3:00:00 
#PBS -l nodes=2:ppn=12
#PBS -W x=GRES:starccm+1%starccmpar+24
#PBS -j oe
#PBS -S /bin/bash

#   A Basic Star-CCM+ Parallel Job for the OSC Oakley Cluster
#   https://www.osc.edu/supercomputing/software/star_ccm

cd $PBS_0_WORKDIR

cp starccm.sim $TMPDIR

cd $TMPDIR

module load starccm

starccm+ -np 24 -batch -machinefile $PBS_NODEFILE starccm.sim >&output.txt

cp output.txt $PBS_0_WORKDIR
