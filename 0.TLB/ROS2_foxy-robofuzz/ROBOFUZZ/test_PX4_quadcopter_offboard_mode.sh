#!/bin/bash

# This script run inside CONTAINER.

#Debbuging
#set -x                 # activate debugging from here
set +x # desactivate debugging from here

# Use VNC to use gui in HPC without complex configurations. export QT_QPA_PLATFORM=vnc:mode=websocket
# To use a web viewer in http://127.0.0.1:5900 if it's avaible for traditional vnc export QT_QPA_PLATFORM=vnc
# or disable with QT_QPA_PLATFORM=offscreen .Other options export QT_QPA_PLATFORM="vnc:size=1280x720:addr=0.0.0.0" .
# ref: https://github.com/pigshell/qtbase/blob/vnc-websocket/README.md

export DISPLAY=":40" # VNC in 5940
export QT_QPA_PLATFORM=vnc

# Set values generated by singularity-init.sh in /tmp/value/
export HOME="$(cat /tmp/value/c_HOME_PATH)"
export HS_IDNUM="$(cat /tmp/value/IDNUM)"

# Set distro
export ROS_DISTRO=foxy

echo "+ [${HS_IDNUM}] Testing PX4 quadcopter - Testing the offboard mode (via ROS trajectory setpoint) +"

# Setting ROS2 + robofuzz enviroment
source "/opt/ros/$ROS_DISTRO/setup.bash"
source "/robofuzz/ros2_foxy/install/setup.bash"
source "/robofuzz/targets/px4_ros_com_ros2/install/setup.bash"
source "/robofuzz/targets/idltest_ws/install/setup.bash"
source "/robofuzz/targets/turtlebot3_ws/install/setup.bash"
source "/robofuzz/targets/moveit2_ws/install/setup.bash"

# Run fuzzer
cd /robofuzz/src
export PYTHONUNBUFFERED=1
python3 -u ./fuzzer.py --px4-sitl-ros --method message --schedule sequence --repeat 1 --watchlist watchlist/px4.json --interval 0.02 >>/log/$(basename $0)_${HS_IDNUM}.pyout
