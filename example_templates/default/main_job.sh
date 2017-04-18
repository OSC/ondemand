# Remove `#torque` prefix to set torque headers and options

#torque #PBS -N hello_world
#torque #PBS -l walltime=00:10:00
#torque #PBS -l nodes=1:ppn=1
#torque #PBS -j oe
#torque cd $PBS_O_WORKDIR

# Remove `#slurm` prefix to set slurm headers and options

#slurm #SBATCH --job-name=hello_world
#slurm #SBATCH --output=res.txt
#slurm #SBATCH --ntasks=1
#slurm #SBATCH --time=10:00
#slurm #SBATCH --mem-per-cpu=100
#slurm cd $SLURM_SUBMIT_DIR

echo "Hello World" > output_file

echo "Created output file with 'Hello World'"
