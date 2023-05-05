#!/bin/bash

#SBATCH --array=0
#SBATCH --ntasks=1
#SBATCH --job-name=exec-robofuzz-args
#SBATCH --mail-user=no-reply@estudiantes.unileon.es
#SBATCH --mail-type=ALL
#SBATCH --output=./log/exec-robofuzz-args-%A-%a.out
#SBATCH --error=./log/exec-robofuzz-args-%A-%a.err
#SBATCH --partition=haswell
#SBATCH --qos=normal
#SBATCH --time=0-72:00:00

#SBATCH --nodes=1
#SBATCH --tasks-per-node=1

### POK ###
# Doesn't work python with stdout, needs a workaround to use an unbuffered output to file.
module load broadwell/singularity_3.2.1
#module load sandybridge/singularity_3.7.0

### PENDING TEST ###
# module load broadwell/singularity_2.5.2
# module load broadwell/singularity_3.0.0
# module load broadwell/singularity_3.1.1
# module load broadwell/singularity_3.6.0
# module load haswell/singularity_2.6.0
# module load haswell/singularity_3.0.0
# module load haswell/singularity_3.1.1
# module load sandybridge/singularity_3.2.1

#Takes firt param as arguments. Ex: script.slurm "arg1 arg2 arg3"
_arguments=$1
_step="exec-robofuzz-args"
# EPOCH (millisecons)
echo "## ## Starting step ${_step} with the argument(s) "${_arguments}" at $(date) epoch $(date +%s%3N) ## ##"
srun ./singularity-init.sh app ROS2_foxy-robofuzz.sif ROBOFUZZ_exec ${_arguments}
echo "## ## Completed step ${_step} with the argument(s) "${_arguments}" at $(date) epoch $(date +%s%3N) ## ##"
