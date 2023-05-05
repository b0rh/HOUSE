#!/bin/bash -x

#SBATCH --array=0
#SBATCH --ntasks=1
#SBATCH --job-name=prepare-coreutils_code
#SBATCH --mail-user=no-reply@estudiantes.unileon.es
#SBATCH --mail-type=ALL 
#SBATCH --output=./log/prepare-coreutils_code_%A_%a.out 
#SBATCH --error=./log/prepare-coreutils_code_%A_%a.err 
#SBATCH --partition=haswell 
#SBATCH --qos=normal 
#SBATCH --time=0-00:01:00 

#SBATCH --nodes=1
#SBATCH --tasks-per-node=1

_version=8.32
_step=prepare-coreutils_code


# EPOCH (millisecons)
echo "## ## Starting step ${_step} at $(date) epoch $(date +%s%3N) ## ##"

srun time bash -x init.sh ${_version} 

echo "## ## Completed step ${_step} at $(date) epoch $(date +%s%3N) ## ##"
