#!/bin/bash

# This script run in HOST and embedded a script that run inside CONTAINER.

# Benchmarking Move It 2 + PANDA manipulator
# Usage docker-robofuzz_MI2.sh <timeout>
#     Examples:
#        1 hour: docker-robofuzz_MI2.sh 1h
#        30 minutes: docker-robofuzz_MI2.sh 30m

#Debbuging
#set -x                 # activate debugging from here
set +x                  # desactivate debugging from here

_basePath=$(pwd) # Current path (./) or execution basepath (from framework House, HS.conf)

HS_TIMEOUT=$1 # Define timeout using firt argument of script
HS_IDNUM=$(date +%s%3N) # EPOCH time with miliseconds 
COMMAND="python3 -u ./fuzzer.py --test-moveit --watchlist watchlist/moveit2.json --no-cov"

# Execute the following commands one time to cache de robofuzz container image and uncomment to check for update every execution:
# Ref: https://github.com/sslab-gatech/RoboFuzz#getting-robofuzz
# docker pull ghcr.io/sslab-gatech/robofuzz:latest
# docker tag ghcr.io/sslab-gatech/robofuzz:latest robofuzz:latest

#ROBOFUZZ_img=1dd4fefe4fb6
ROBOFUZZ_img=robofuzz

# Host(h) stdout filepath
h_OUTPUT_FILEPATH="${_basePath}/log/$(basename $0)_${HS_TIMEOUT}_${HS_IDNUM}.out"

# Check use of timeout
if [ -z ${HS_TIMEOUT} ];then # If it is not define. Embedded command without TIMEOUT limit.
    EMBEDDED_COMMAND="$(echo $COMMAND)"
else # Embedded command with TIMEOUT limit.
    echo "INFO: TIMEOUT value $HS_TIMEOUT ."
    EMBEDDED_COMMAND="time timeout $HS_TIMEOUT $(echo $COMMAND)"
fi

# Launcher script
# Write script to variable to inject has parameter in runcontainer command
# The following script run inside CONTAINER.

SCRIPT=$(cat <<EOF
# Installs timeout tool to limit process execution time
apt-get install -y timelimit

echo "+ [${HS_IDNUM}] Benchmarking Move It 2 + PANDA manipulator for $HS_TIMEOUT +"

# Load eviroment variables
source /ros_entrypoint.sh
source /opt/ros/foxy/setup.bash
source /robofuzz/ros2_foxy/install/setup.bash
source /robofuzz/targets/px4_ros_com_ros2/install/setup.bash
source /robofuzz/targets/idltest_ws/install/setup.bash
source /robofuzz/targets/turtlebot3_ws/install/setup.bash
source /robofuzz/targets/moveit2_ws/install/setup.bash

# Command to benchmark
cd /robofuzz/src
export PYTHONUNBUFFERED=1
$(echo $EMBEDDED_COMMAND)
EOF
)

# Crete binding/auxiliar directory structure between containers and host
mkdir -p log
touch $h_OUTPUT_FILEPATH

# RUN a test inside docker cointainer binding X11 context, inject script and set output to a file.
docker run --rm -it \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --name RZ_MI2_${HS_TIMEOUT}_${HS_IDNUM} $ROBOFUZZ_img \
    bash -c "$SCRIPT" >> $(echo $h_OUTPUT_FILEPATH)
