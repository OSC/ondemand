#PBS -N ansys_test  
#PBS -l walltime=30:00:00  
#PBS -l nodes=1:ppn=1
#PBS -l software=ansys+1  
#PBS -j oe

# A basic Ansys Mechanical Job
# Further details at: 
#	https://www.osc.edu/documentation/software_list/ansys_mechanical

cd $TMPDIR  
cp $PBS_O_WORKDIR/ansys.in .    
module load ansys  
ansys < ansys.in   
cp * $PBS_O_WORKDIR