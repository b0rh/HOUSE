#!/bin/bash

# This script run in HOST and embedded a script that run inside CONTAINER.

#Debbuging
#set -x                 # activate debugging from here
set +x                  # desactivate debugging from here

_basePath=$(pwd) # Current path (./) or execution basepath (from framework House, HS.conf)
HS_IDNUM=$(date +%s%3N) # EPOCH time with miliseconds 

# Execute the following commands one time to cache de robofuzz container image and uncomment to check for update every execution:
# Ref: https://github.com/sslab-gatech/RoboFuzz#getting-robofuzz
# docker pull ghcr.io/sslab-gatech/robofuzz:latest
# docker tag ghcr.io/sslab-gatech/robofuzz:latest robofuzz:latest

#ROBOFUZZ_img=1dd4fefe4fb6
ROBOFUZZ_img=robofuzz

# Host(h) stdout filepath
h_OUTPUT_FILEPATH="${_basePath}/log/$(basename $0)_${HS_IDNUM}.out"

# Launcher script
# Write script to variable to inject has parameter in runcontainer command
# The following script run inside CONTAINER.
SCRIPT=$(cat <<EOF

# Run testsuites: sysbench, fs-mark and byte

# Default paths
_userHome="$HOME/$(whoami)"
_default_phoronix_path="${_userHome}/.phoronix-test-suite/"

# Install phoronix-test-suite and dependencies
# https://github.com/phoronix-test-suite/phoronix-test-suite/blob/master/documentation/phoronix-test-suite.md

# From source intalls
#mkdir -p /opt
#cd /opt
#wget https://phoronix-test-suite.com/releases/phoronix-test-suite-10.8.4.tar.gz
#tar xfvz phoronix-test-suite-10.8.4.tar.gz

# From package
apt-get update && apt-get install -y \
    php-cli \
    php-common \
    php-gd \
    php-fdomdocument \
    php-dompdf \
    php-zip \
    php-curl \
    php-xml \
    php-json \
    php-fpdf \
    php-bz2 \
    php-sqlite3 \
    xz-utils

cd /tmp
wget https://phoronix-test-suite.com/releases/repo/pts.debian/files/phoronix-test-suite_10.8.4_all.deb
yes 4 | dpkg -i phoronix-test-suite_10.8.4_all.deb

rm /tmp/phoronix-test-suite_10.8.4_all.deb

# Install testsuites

# CPU TESTSUITE COLLECTION -  https://openbenchmarking.org/suite/pts/cpu
# to install all collection: phoronix-test-suite install pts/cpu
phoronix-test-suite install pts/sysbench
#phoronix-test-suite install pts/radiance
#phoronix-test-suite install pts/openssl

# DISK TESTSUITE COLLECTION -  https://openbenchmarking.org/suite/pts/disk
# to install all collection: phoronix-test-suite install pts/disk
#phoronix-test-suite install pts/fio
phoronix-test-suite install pts/fs-mark

# MEMORY TESTSUITE COLLECTION -  https://openbenchmarking.org/suite/pts/memory
# to install all collection: phoronix-test-suite install pts/memory
phoronix-test-suite install pts/memory

# MULTICORE TESTSUITE COLLECTION -  https://openbenchmarking.org/suite/pts/multicore
# to install all collection: phoronix-test-suite install pts/multicore
phoronix-test-suite install pts/coremark

# NETWORK TESTSUITE COLLECTION -  https://openbenchmarking.org/suite/pts/network
# to install all collection: phoronix-test-suite install pts/network
phoronix-test-suite install pts/network
phoronix-test-suite install pts/iperf

# COMPUTATIONAL TESTSUITE COLLECTION -  https://openbenchmarking.org/suite/pts/computational
# to install all collection: phoronix-test-suite install pts/computational
phoronix-test-suite install pts/byte
phoronix-test-suite install pts/scimark2

# Checks install
phoronix-test-suite list-installed-tests
phoronix-test-suite list-test-status

phoronix-test-suite system-info
phoronix-test-suite system-sensors

# Configures batch
# Ref: https://gist.github.com/anshula/728a76297e4a4ee7688d#batch-mode
# Running interactive batch conf generator to create files ~/.phoronix-test-suite/user-config.xml
# Use  docker attach Container name to complete batch-setupecho

echo 
echo " ****************************************************************
echo " * Use  docker attach <Container_name> to complete batch-setup  *
echo " * Recommended: YNnnnnY
echo " ****************************************************************
echo 

phoronix-test-suite batch-setup

# Run testsuite in batch using ~/.phoronix-test-suite/user-config.xml

# Ref: https://openbenchmarking.org/test/pts/sysbench
phoronix-test-suite batch-run pts/sysbench

# Ref: https://openbenchmarking.org/test/pts/byte
phoronix-test-suite batch-run run pts/byte

# Ref: https://openbenchmarking.org/test/pts/fs-mark
phoronix-test-suite batch-run run pts/fs-mark

# To export results
# Ref: https://github.com/phoronix-test-suite/phoronix-test-suite/blob/master/documentation/phoronix-test-suite.md#result-export
# Raw results in

echo "RAW resuls in ${_default_phoronix_path}test-results/"
echo "Last test:"
find ${_default_phoronix_path}/test-results/ -type f
EOF
)

# Crete binding/auxiliar directory structure between containers and host
mkdir -p log
touch $h_OUTPUT_FILEPATH

# RUN testsuites inside docker cointainer binding X11 context, inject script and set output to a file.
docker run --rm -it \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --name RZ_PHORONIX_${HS_TIMEOUT}_${HS_IDNUM} $ROBOFUZZ_img \
    bash -c "$SCRIPT" >> $(echo $h_OUTPUT_FILEPATH)