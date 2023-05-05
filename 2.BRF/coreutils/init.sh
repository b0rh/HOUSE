#Load HS enviroment variables
source ../../HS.conf

# Creates directory layout
mkdir files log src -p

# Local variables
_version=$1
_in="${HS_ROOT}/1.SCI/coreutils/files/coreutils-${_version}"
_out="${HS_ROOT}/2.BRF/coreutils/files/coreutils-${_version}"

# Copy prepared code

cp $_in ./src/ -r

# Set default compilers and AFL_PATH (for afl-gcc, the var change between afl-gcc and afl-fuzz)
CC="$HS_CC"
#CPP="$HS_CC" # Preprocesor
CCX="$HS_CCX"
AFL_PATH="$TLB_AFL_PATH_COMPILE"


# Add custom auxiliar binaries to path

# WORKAROUND:# aclocal and automake depencies from source code patching enviroment paths.
PATH=${PATH}:${HS_ROOT}/0.TLB/automake/files/bin
# WORKAROUND:# gperf dependency copied from centos 7 rpm storage in 0.TLB/gperf
PATH=${PATH}:${HS_ROOT}/0.TLB/gperf/usr/bin

# Set source path
cd ./src/coreutils-${_version}

export CC="$HS_CC"
export CCX="$HS_CCX"
export AFL_PATH="$TLB_AFL_PATH_COMPILE"
# Add custom auxiliar binaries to enviromente PATH
export PATH=${PATH}:${AFL_PATH}

# Make & configure using HS CC and CCX compilers
./configure CC="$HS_CC" CCX="$HS_CCX" AFL_PATH="$TLB_AFL_PATH_COMPILE" PATH="${PATH}"


mkdir -p ${_out}
make install DESTDIR="${_out}"
