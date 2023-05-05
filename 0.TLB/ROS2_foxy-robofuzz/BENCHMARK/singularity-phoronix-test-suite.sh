#!/bin/bash

# This script run inside CONTAINER.

# Run testsuites: sysbench, fs-mark and byte

#Debbuging
#set -x                 # activate debugging from here
set +x # desactivate debugging from here

## Set enviroment values
#if [ -z ${HS_IDNUM} ]; then # If it is not define use EPOCH time
#    # EPOCH time with miliseconds
#    HS_IDNUM=$(date +%s%3N)
#fi

# WORKAROUND to fix default path conf
_userHome="$HOME/$(whoami)"
_default_phoronix_path="${_userHome}/.phoronix-test-suite/"

## Output file for phoronix results
#c_OUTPUT_FILEPATH="/log/$(basename $0)_${HS_IDNUM}.phout"

# Create default phoronix path. Change path in conf does not work, some testsuite has hardcoded the default path.
mkdir -p ${_default_phoronix_path}

# Solve HPC homepath scheme $HOME/<main_user_group>/<user_name>
for GRP in $(groups); do
    mkdir -p $HOME/$GRP
    ln -s $_userHome $HOME/$GRP/$(whoami)
done

# Extract  phoronix test suite installed test
# reload using default name .phoronix-test-suite
# TODO: using https://github.com/phoronix-test-suite/phoronix-test-suite/blob/master/documentation/phoronix-test-suite.md#backup-creation--restore
tar xfz /_outside_/phoronix-test-suite_cache_test_directory.tgz -C ${_userHome} --skip-old-files

# Checks install
phoronix-test-suite list-installed-tests
phoronix-test-suite list-test-status

phoronix-test-suite system-info
phoronix-test-suite system-sensors

# Configures batch
# Ref: https://gist.github.com/anshula/728a76297e4a4ee7688d#batch-mode
# Running interactive batch conf generator to create files ~/.phoronix-test-suite/user-config.xml
# phoronix-test-suite batch-setup
# Autoconf batch-setup
#    Save test results when in batch mode (Y/n): Y
#    Open the web browser automatically when in batch mode (y/N): N
#    Auto upload the results to OpenBenchmarking.org (Y/n): n
#    Prompt for test identifier (Y/n): n
#    Prompt for test description (Y/n): n
#    Prompt for saved results file-name (Y/n): n
#    Run all test options (Y/n): Y

for OPT in Y N n n n n Y; do
    echo $OPT
    sleep 0.3s
done | phoronix-test-suite batch-setup

# Save default phoronix directory with all test installed and batch conf
# cd ${_userHome}
# tar cfvz  /_outside_/phoronix-test-suite_cache_test_directory_$(cat /tmp/value/IDNUM).tgz .phoronix-test-suite

# Run testsuite interactively
#phoronix-test-suite run pts/sysbench
#phoronix-test-suite run pts/byte
#phoronix-test-suite run pts/fs-mark

# Run full testsuite interactively
#phoronix-test-suite run-tests-in-suite pts/sysbench

# Run testsuite in batch using ~/.phoronix-test-suite/user-config.xml

# Ref: https://openbenchmarking.org/test/pts/sysbench
#phoronix-test-suite batch-run pts/sysbench >>$(echo $c_OUTPUT_FILEPATH)
phoronix-test-suite batch-run pts/sysbench

# Ref: https://openbenchmarking.org/test/pts/byte
#phoronix-test-suite batch-run run pts/byte >>$(echo $c_OUTPUT_FILEPATH)
phoronix-test-suite batch-run run pts/byte

# Ref: https://openbenchmarking.org/test/pts/fs-mark
#phoronix-test-suite batch-run run pts/fs-mark >>$(echo $c_OUTPUT_FILEPATH)
phoronix-test-suite batch-run run pts/fs-mark 
# To export results
# Ref: https://github.com/phoronix-test-suite/phoronix-test-suite/blob/master/documentation/phoronix-test-suite.md#result-export
# Raw results in

echo "RAW resuls in ${_default_phoronix_path}test-results/"
echo "Last test:"
find ${_default_phoronix_path}/test-results/ -type f
