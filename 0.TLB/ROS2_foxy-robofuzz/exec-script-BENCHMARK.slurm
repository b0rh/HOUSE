#!/bin/bash

# Special to reserve a complete node for script execution

#SBATCH --array=0
#SBATCH --ntasks=1
#SBATCH --job-name=check-robofuzz-install
#SBATCH --mail-user=no-reply@estudiantes.unileon.es
#SBATCH --mail-type=ALL
#SBATCH --output=./log/exec-script-ROS2-robofuzz-%A-%a.out
#SBATCH --error=./log/exec-script-ROS2-robofuzz-%A-%a.err
#SBATCH --partition=haswell
#SBATCH --qos=normal
#SBATCH --time=0-72:00:00

#SBATCH --mem=0
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --ntasks-per-core=0.5


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

#Takes firt param as arguments. Ex:exec_script-ROS2-robofuzz.slurm script.sh "arg1 arg2 arg3" _script=script.sh _arguments="arg1 arg2 arg3"
_script=$1
_arguments=$2
_step="exec_script-ROS2-robofuzz"
# EPOCH (millisecons)
echo "## ## Starting step ${_step} with the script "${_script}" and argument(s) "${_arguments}" at $(date) epoch $(date +%s%3N) ## ##"
srun ./singularity-init.sh script ROS2_foxy-robofuzz.sif ${_script} $(echo ${_arguments})
echo "## ## Completed step ${_step} with the script "${_script}" and the argument(s) "${_arguments}" at $(date) epoch $(date +%s%3N) ## ##"
