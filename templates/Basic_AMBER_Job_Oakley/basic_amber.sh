#PBS -N 6pti
#PBS -l nodes=1:ppn=1
#PBS -l walltime=0:20:00

# AMBER Example Batch Script for the Basic Tutorial in the Amber manual
# 	Additional details at: https://www.osc.edu/supercomputing/software/amber

module load amber
# Use TMPDIR for best performance.
cd $TMPDIR
# PBS_O_WORKDIR refers to the directory from which the job was submitted.
cp -p $PBS_O_WORKDIR/6pti.prmtop .
cp -p $PBS_O_WORKDIR/6pti.prmcrd .
# Running minimization for BPTI
cat << eof > min.in
# 200 steps of minimization, generalized Born solvent model
&cntrl
maxcyc=200, imin=1, cut=12.0, igb=1, ntb=0, ntpr=10,
/
eof
sander -i min.in -o 6pti.min1.out -p 6pti.prmtop -c 6pti.prmcrd -r 6pti.min1.xyz
cp -p min.in 6pti.min1.out 6pti.min1.xyz $PBS_O_WORKDIR
