#PBS -l walltime=01:00:00
#PBS -l nodes=2:ppn=20
#PBS -N COMSOL
#PBS -j oe
#PBS -r n
#PBS -l software=comsolscript

#  A Basic COMSOL Parallel Job for the OSC Oakley Cluster
#  https://www.osc.edu/supercomputing/software/comsol

cd ${PBS_O_WORKDIR}
module load comsol
echo "--- Copy Input Files to TMPDIR and Change Disk to TMPDIR"
cp input_cluster.mph $TMPDIR
cd $TMPDIR
np=12
echo "--- Running on ${np} processes (cores) on the following nodes:"
cat $PBS_NODEFILE | uniq > hostfile
echo "--- COMSOL run"
comsol -nn 2 -np ${np} batch -f hostfile -mpirsh rsh -inputfile input_cluster.mph -outputfile output_cluster.mph
echo "--- Copy files back"
cp output_cluster.mph output_cluster.mph.status ${PBS_O_WORKDIR}
echo "---Job finished at: 'date'"
echo "---------------------------------------------"