#!/bin/bash
#set -x

# Build TGZ file with installed test suite
# NOTE: Take care of align with definition file to also install system dependencies, it's only for filesytem layout.

# WORKAROUND to fix default path conf
_userHome="$HOME/$(whoami)"
_default_phoronix_path="${_userHome}/.phoronix-test-suite/"

mkdir -p  ${_default_phoronix_path}

## Extract  phoronix test suite installed test
#tar xfz /_outside_/phoronix-test-suite_cache_test_directory.tgz -C $HOME --skip-old-files
#mv /home/phoronix-test-suite/ ${_default_phoronix_path}

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
phoronix-test-suite install pts/memor

# MULTICORE TESTSUITE COLLECTION -  https://openbenchmarking.org/suite/pts/multicore
# to install all collection: phoronix-test-suite install pts/multicore
phoronix-test-suite install pts/coremar

# NETWORK TESTSUITE COLLECTION -  https://openbenchmarking.org/suite/pts/network
# to install all collection: phoronix-test-suite install pts/network
phoronix-test-suite install pts/network
phoronix-test-suite install pts/iperf

# COMPUTATIONAL TESTSUITE COLLECTION -  https://openbenchmarking.org/suite/pts/computational
# to install all collection: phoronix-test-suite install pts/computational
phoronix-test-suite install pts/byte
phoronix-test-suite install pts/scimark2


phoronix-test-suite list-test-status
phoronix-test-suite list-installed-tests

# Save default phoronix directory with all test installed
cd ${_userHome}
tar cfvz  /_outside_/phoronix-test-suite_cache_test_directory_$(cat /tmp/value/IDNUM).tgz .phoronix-test-suite

