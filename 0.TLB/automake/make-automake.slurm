#!/bin/bash -x

#SBATCH --array=0
#SBATCH --ntasks=1
#SBATCH --job-name=make-automake
#SBATCH --mail-user=no-reply@estudiantes.unileon.es
#SBATCH --mail-type=ALL 
#SBATCH --output=./log/make-automake_%A_%a.out 
#SBATCH --error=./log/make-automake_%A_%a.err 
#SBATCH --partition=haswell 
#SBATCH --qos=normal 
#SBATCH --time=0-00:01:00 

#SBATCH --nodes=1
#SBATCH --tasks-per-node=1


module load cascadelake/cmake_3.16.4_gcc9.2.0
#module load haswell/cmake_3.16.4_gcc8.2.0


_version=1.16.3
_step=make-automake
# EPOCH (millisecons)
echo "## ## Starting step ${_step} at $(date) epoch $(date +%s%3N) ## ##"
srun time bash -x init.sh
echo "## ## Completed step ${_step} at $(date) epoch $(date +%s%3N) ## ##"
