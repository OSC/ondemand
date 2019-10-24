#PBS -N hello_world
#PBS -l walltime=00:10:00
#PBS -l nodes=1:ppn=1
#PBS -j oe

cd $PBS_O_WORKDIR
echo "Hello World" > output_file

echo "Created output file with 'Hello World'"
