#PBS -N hello_world
#PBS -l walltime=00:10:00
#PBS -l nodes=1:ppn=1
#PBS -j oe

echo "Hello World" > output_file
