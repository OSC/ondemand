#PBS -N myscience
#PBS -l walltime=40:00:00
#PBS -l nodes=1:ppn=1
#PBS -j oe

# The following is an example of a single-processor sequential job that uses $TMPDIR as its working area.
# It assumes that the program mysci has already been built. The script copies its input file from the directory
# the qsub command was called from into $TMPDIR, runs the code in $TMPDIR,
# and copies the output files back to the original directory.
#   https://www.osc.edu/supercomputing/batch-processing-at-osc/job-scripts

cd $PBS_O_WORKDIR

cp mysci.in $TMPDIR

cd $TMPDIR

/usr/bin/time ./mysci > mysci.hist

cp mysci.hist mysci.out $PBS_O_WORKDIR
