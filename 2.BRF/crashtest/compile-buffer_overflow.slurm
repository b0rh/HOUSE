#!/bin/bash -x

#SBATCH --array=0
#SBATCH --ntasks=1
#SBATCH --job-name=compile-crashtest
#SBATCH --mail-user=no-reply@estudiantes.unileon.es
#SBATCH --mail-type=ALL 
#SBATCH --output=./log/compile-crashtest_%A_%a.out 
#SBATCH --error=./log/compile-crashtest_%A_%a.err 
#SBATCH --partition=haswell 
#SBATCH --qos=normal 
#SBATCH --time=0-01:00:00 

#SBATCH --nodes=1
#SBATCH --tasks-per-node=1

# Load WLP context variables
source target.conf

# EPOCH (millisecons)
echo "## ## Starting step ${_step} at $(date) epoch $(date +%s%3N) ## ##"
srun time bash -x init.sh 
echo "## ## Completed step ${_step} at $(date) epoch $(date +%s%3N) ## ##"
