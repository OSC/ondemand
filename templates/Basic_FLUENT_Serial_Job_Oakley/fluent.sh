#PBS -N serial_fluent
#PBS -l walltime=5:00:00 
#PBS -l nodes=1:ppn=1
#PBS -l software=fluent+1
#PBS -j oe

# A basic FLUENT Serial Job
# Further details available at:
# 	https://www.osc.edu/supercomputing/software/fluent

#
# The following lines set up the FLUENT environment
#
module load fluent
#
# Move to the directory where the job was submitted from
# You could also 'cd' directly to your working directory
cd $PBS_O_WORKDIR
#
# Copy files to $TMPDIR and move there to execute the program
#
cp test_input_file.cas test_input_file.dat run.input $TMPDIR
cd $TMPDIR
#
# Run fluent
fluent 3d -g < run.input  
#
# Where the file 'run.input' contains the commands you would normally
# type in at the Fluent command prompt.
# Finally, copy files back to your home directory
cp *   $PBS_O_WORKDIR  