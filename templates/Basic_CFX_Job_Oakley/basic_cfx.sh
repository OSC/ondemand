#PBS -N serialjob_cfx
#PBS -l walltime=1:00:00
#PBS -l software=fluent+1
#PBS -l nodes=1:ppn=1
#PBS -j oe
#PBS -S /bin/bash

# A basic CFX Job
# Further details at:
#	https://www.osc.edu/supercomputing/software/cfx

#Set up CFX environment.
module load fluent
#'cd' directly to your working directory
cd $PBS_O_WORKDIR
#Copy CFX files like .def to $TMPDIR and move there to execute the program
cp test.def $TMPDIR/
cd $TMPDIR
#Run CFX in serial with test.def as input file
cfx5solve -batch -def test.def 
#Finally, copy files back to your home directory
cp  * $PBS_O_WORKDIR