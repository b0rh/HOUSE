#!/bin/bash -x

#SBATCH --array=0
#SBATCH --ntasks=1
#SBATCH --job-name=compile-coreutils
#SBATCH --mail-user=no-reply@estudiantes.unileon.es
#SBATCH --mail-type=ALL 
#SBATCH --output=./log/compile-coreutils_%A_%a.out 
#SBATCH --error=./log/compile-coreutils_%A_%a.err 
#SBATCH --partition=haswell 
#SBATCH --qos=normal 
#SBATCH --time=0-01:00:00 

#SBATCH --nodes=1
#SBATCH --tasks-per-node=1

# Module with compilation tools
module load cascadelake/cmake_3.16.4_gcc9.2.0
#module load cascadelake/gcc_9.2.0

_version=8.32
_step=compile-coreutils


# EPOCH (millisecons)
echo "## ## Starting step ${_step} at $(date) epoch $(date +%s%3N) ## ##"

srun time bash -x init.sh ${_version} 

echo "## ## Completed step ${_step} at $(date) epoch $(date +%s%3N) ## ##"
