#!/bin/bash -x

#SBATCH --array=0
#SBATCH --ntasks=1
#SBATCH --mem=1gb                   # Job Memory
#SBATCH --job-name=MF-aflfuzzer
#SBATCH --mail-user=xxxxx@estudiantes.unileon.es
#SBATCH --mail-type=END  # Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --output=./log/MF-aflfuzzer.%A_%a.out 
#SBATCH --error=./log/MF-aflfuzzer.%A_%a.err 
#SBATCH --partition=haswell 
#SBATCH --qos=normal 
#SBATCH --time=4-0:00:00 

#SBATCH --nodes=1              # Number of nodes
#SBATCH --ntasks=1             # Number of MPI ranks

# Load WLP context variables
source target.conf

# Add job to list
echo $SLURM_JOB_ID >> jobs.lst

# EPOCH (millisecons) $(date +%s%3N)
echo "## ## Starting step ${_step} at $(date) epoch $(date +%s%3N) ## ##"

srun time bash -x master-init.sh $SLURM_JOB_ID 

echo "## ## Completed step ${_step} at $(date) epoch $(date +%s%3N) ## ##"
