#!/bin/bash

# This script run in HOST.

show_help() {
    printf "%s\n" \
        "Usage $(basename $0) <mode shell | app | script> <SIF singularity image file> <apprun_name | script>" \
        "   Example app: $(basename $0) app ROS2_foxy-robofuzz.sif  ROS2_demo_FastRTPS_talker" \
        "   Example app + arg: $(basename $0) app ROS2_foxy-robofuzz.sif  ROBOFUZZ_exec 'ARG1 ARG2 ARG3'" \
        "   Example shell: $(basename $0) shell ROS2_foxy-robofuzz.sif " \
        "   Example script: $(basename $0) script ROS2_foxy-robofuzz.sif  ./TEMPLATE/example.sh 'ARG1 ARG2 ARG3'"
}

#Debbuging
#set -x                 # activate debugging from here
set +x # desactivate debugging from here

_basePath=$(pwd) # Current path (./) or execution basepath (from framework House, HS.conf)
#Load HS enviroment variables
#source ../../HS.conf

_singularityMode=$1
_singularityImagePath=$2
_singularityApprunSC=$3
_singularityAppSCArguments=$4

# Setup bindings

# Crete binding directory structure between containers and host
mkdir -p log home tmp

# Create a new subdirectory inside host temporal, home and robofuzz files for each run with the EPOCH time in name or JOBID (if it's manage by slurm),
# and bind inside container as default temporal. This allows multiple parallel runs of robofuzz
# simultaneously and solves the use of read only images.

if [ -z ${SLURM_JOB_ID} ]; then # If it is not define use EPOCH time
    # EPOCH time with miliseconds
    IDNUM=$(date +%s%3N)
else # Use $SLURM_JOB_ID if it exits.
    IDNUM=${SLURM_JOB_ID}
fi

# BINDS
#          host(h_)          -      container (c_)
#   -------------------           -------------------
# ./robofuzz/{IDNUM}/src    <->      /robofuzz/src/      # Fuzzer cases and results output
# ./log/                    <->      /log/               # Stderr and Stdout container logs
# ./tmp/{IDNUM}/            <->      /tmp/               # Temporal files as lock and test case control
# ./                        <->      {c_OUTSIDE_PATH}    # Host basepath directory share inside container
# ./home/{IDNUM}/           <->      /home/              # Home directory

c_OUTSIDE_PATH='/_outside_/'
h_ROBOFUZZ_SRC_FILEPATH="${_basePath}/robofuzz_src_directory.tgz"
#h_PHORONIX_TS_SRC_FILEPATH="${_basePath}/phoronix-test-suite_cache_test_directory.tgz"
h_TMP_PATH="${_basePath}/tmp/${IDNUM}/"
h_ROBOFUZZ_PATH="${_basePath}/robofuzz/${IDNUM}/"
h_LOG_PATH="${_basePath}/log/"
h_HOME_PATH="${_basePath}/home/${IDNUM}/"
c_HOME_PATH='/home/'

# Host directory layout
mkdir -p ${h_TMP_PATH}
mkdir -p ${h_ROBOFUZZ_PATH}
mkdir -p ${h_HOME_PATH}

# TODO: Move to inside script using _outside_ to acces to file. Similar to a BENCHMARK/docker-phoronix-test-suite.sh with phoronix tgz file.
# Extract Robofuzz SRC and TS
tar xfz ${h_ROBOFUZZ_SRC_FILEPATH} -C ${h_ROBOFUZZ_PATH} --skip-old-files

# Extract  phoronix test suite installed test
#tar xfz ${h_PHORONIX_TS_SRC_FILEPATH} -C ${h_HOME_PATH} --skip-old-files

_singularityBindsPaths=$(echo "${h_ROBOFUZZ_PATH}/src/:/robofuzz/src/:rw,${h_LOG_PATH}:/log:rw,${h_TMP_PATH}:/tmp:rw,${_basePath}/:${c_OUTSIDE_PATH}:rw,${h_HOME_PATH}:${c_HOME_PATH}:rw")

# MAP ENVIROMENTS VALUES to a files

#Add IDNUM value to /tmp/value/IDNUM
mkdir -p ${h_TMP_PATH}/value/

echo ${IDNUM} >${h_TMP_PATH}/value/IDNUM
echo ${c_HOME_PATH} >${h_TMP_PATH}/value/c_HOME_PATH

### Checks and applies script parameter

if [ -z ${_singularityMode} ]; then # Checks mode.
    echo "ERROR: Mode was not set."
    show_help
    exit 1
elif [ -z ${_singularityImagePath} ]; then # Checks the existence of SIG image parameter.
    echo "ERROR: SIF Singularity image  was not set."
    show_help
    exit 1
elif [ ! -e ${_singularityImagePath} ]; then # Checks is accessible the sif file .
    echo "ERROR: Could not access to SIF file "${_singularityImagePath}"."
    show_help
    exit 1
else # Check mode
    case $_singularityMode in
    shell)
        echo "INFO: INITializing Singularity SHELL in image ${_singularityImagePath} at $(date) epoch $(date +%s%3N)."
        singularity shell --no-home --cleanenv -B ${_singularityBindsPaths} ${_singularityImagePath}
        echo "INFO: EXITing Singularity SHELL in image ${_singularityImagePath} at $(date) epoch $(date +%s%3N)."
        ;;
    app)
        if [ -z ${_singularityApprunSC} ]; then # Checks mode.
            echo "ERROR: Apprun name was not set."
            show_help
            exit 1
        else
            echo "INFO: INITializing Singularity APP ${_singularityApprunSC} in image ${_singularityImagePath} at $(date) epoch $(date +%s%3N)."
            singularity run --no-home --app ${_singularityApprunSC} --cleanenv -B ${_singularityBindsPaths} ${_singularityImagePath} ${_singularityAppSCArguments}
            echo "INFO: EXITing Singularity APP ${_singularityApprunSC} in image ${_singularityImagePath} at $(date) epoch $(date +%s%3N)."
        fi
        ;;
    script)
        if [ -z ${_singularityApprunSC} ]; then # Checks the existence of script parameter.
            echo "ERROR: script filepath  was not set."
            exit 1
        elif [ ! -e ${_singularityApprunSC} ]; then # Checks is accessible the script file .
            echo "ERROR: Could not access to script file "${_singularityApprunSC}"."
            exit 1
        else
            echo "INFO: INITializing Singularity SCRIPT ${_singularityApprunSC} in image ${_singularityImagePath} at $(date) epoch $(date +%s%3N)."
            chmod +x ${_singularityApprunSC}
            # To use /_outside_/ directory in place of independent tmp for each job, be care if you share scripts between job when enable this option.
            #echo "singularity exec --cleanenv -B ${_singularityBindsPaths}  ${_singularityImagePath}  ${c_OUTSIDE_PATH}/$(echo $_singularityApprunSC) ${_singularityAppSCArguments}"
            #singularity exec  --no-home --cleanenv -B ${_singularityBindsPaths}  ${_singularityImagePath}  ${c_OUTSIDE_PATH}/$(echo $_singularityApprunSC) ${_singularityAppSCArguments}

            # Copy script to instance temporal directory
            cp ${_singularityApprunSC} ${h_TMP_PATH}
            singularity exec --no-home --cleanenv -B ${_singularityBindsPaths} ${_singularityImagePath} /tmp/$(echo $(basename $_singularityApprunSC)) ${_singularityAppSCArguments}
            echo "INFO: EXITing Singularity SCRIPT ${_singularityApprunSC} in image ${_singularityImagePath} at $(date) epoch $(date +%s%3N)."
        fi
        ;;
    *) # Show help
        show_help
        ;;
    esac
fi
