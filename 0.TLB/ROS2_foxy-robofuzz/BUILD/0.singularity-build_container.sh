#!/bin/bash

show_help() {
    printf '%s\n' \
        'Usage build.sh  <SIF singularity image file> <DEF singularity definition file>' \
        '   Example build.sh ROS2_foxy-robofuzz_Singularity_v10.sif ROS2_foxy-robofuzz_Singularity_v10.def'
}

#Debbuging
#set -x                 # activate debugging from here
set +x # desactivate debugging from here

_basePath=$(pwd) # Current path (./) or execution basepath (from framework House, HS.conf)
#Load HS enviroment variables
#source ../../HS.conf

_singularityImagePath=$1
_singularityDefinitionPath=$2

# Setup BINDINGS

# Crete binding directory structure between containers and host
mkdir -p log home tmp

# Create a new subdirectory inside host temporal, home and robofuzz files for each run with the EPOC time in name or JOBID (if it's manage by slurm),
# and bind inside container as default temporal. This allows multiple parallel runs of robofuzz
# simultaneously and solves the use of read only images.

if [ -z ${SLURM_JOB_ID} ]; then # If it is not define use EPOCH time
    # EPOCH time with miliseconds
    IDNUM=$(date +%s%3N)
else # Use $SLURM_JOB_ID if it exits.
    IDNUM=${SLURM_JOB_ID}
fi

h_TMP_PATH="${_basePath}/tmp/${IDNUM}/"
h_LOG_PATH="${_basePath}/log/"
h_HOME_PATH="${_basePath}/home/${IDNUM}/"
#c_HOME_PATH='/home_alone/'
c_HOME_PATH='/home/'

# Host directory layout
mkdir -p ${h_TMP_PATH}
mkdir -p ${h_HOME_PATH}

# BINDS
#          host(h_)          -      container (c_)
#   -------------------           -------------------
# ./log/                    <->      /log/               # Stderr and Stdout container logs
# ./tmp/{IDNUM}/            <->      /tmp/               # Temporal files as lock and test case control
# ./home/{IDNUM}/           <->      /home/              # Home directory

_singularityBindsPaths=$(echo "${h_LOG_PATH}:/log:rw,${h_HOME_PATH}:${c_HOME_PATH}:rw")
#_singularityBindsPaths=$(echo "${h_LOG_PATH}:/log:rw,${h_TMP_PATH}:/tmp:rw,${h_HOME_PATH}:${c_HOME_PATH}:rw")

# MAP ENVIROMENTS VALUES to a files

#Add IDNUM value to /tmp/value/IDNUM
mkdir -p ${h_TMP_PATH}/value/

echo ${IDNUM} >${h_TMP_PATH}/value/IDNUM
echo ${c_HOME_PATH} >${h_TMP_PATH}/value/c_HOME_PATH

# SET SINGULARITY CACHEDIR y TMPDIR
export SINGULARITY_CACHEDIR=$(echo "${_basePath}/../CACHEDIR")
export SINGULARITY_TMPDIR=$(echo "${_basePath}/../TMPDIR")

mkdir -p $SINGULARITY_CACHEDIR $SINGULARITY_TMPDIR

### Checks and applies script parameter

if [ -z ${_singularityImagePath} ]; then # Checks the existence of image parameter.
    echo "ERROR: SIF Singularity image was not set."
    show_help
    exit 1
elif [ -z ${_singularityDefinitionPath} ]; then # Checks the existence of definition parameter.
    echo "ERROR: DEF Singularity definition was not set."
    show_help
    exit 1
elif [ ! -e ${_singularityDefinitionPath} ]; then # Checks is accessible the def file .
    echo "ERROR: Could not access to DEF file "${_singularityDefinitionPath}"."
    show_help
    exit 1
else # Execute command
    ### Build
    # singularity --debug build -B ${_singularityBindsPaths} ${_singularityImagePath}  ${_singularityDefinitionPath}
    singularity build --fix-perms -B ${_singularityBindsPaths} ${_singularityImagePath} ${_singularityDefinitionPath}

fi
