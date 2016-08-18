#PBS -N parallel_fluent   
#PBS -l walltime=1:00:00   
#PBS -l nodes=2:ppn=12
#PBS -j oe
#PBS -W x=GRES:fluent+1%ansyspar+20
#PBS -S /bin/bash
set echo on   
hostname   
#   
# The following lines set up the FLUENT environment   
#   
module load fluent
#   
# Move to the directory where the job was submitted from and   
# create the config file for socket communication library   
#   
cd $PBS_O_WORKDIR   
#   
# Create list of nodes to launch job on   
rm -f pnodes   
cat  $PBS_NODEFILE | sort > pnodes   
export ncpus=`cat pnodes | wc -l`   
#   
#   Run fluent   
fluent 3d -t$ncpus -pinfiniband.ofed -cnf=pnodes -g < run.input 