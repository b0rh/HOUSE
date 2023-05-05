#Load HS enviroment variables
source ../../HS.conf

#Debbuging
set -x			# activate debugging from here

_basePath=$(pwd)

# Clone git repository and rename to standar stucture name

# Gogle version  (deprecated)
# git clone  https://github.com/google/AFL.git
# mv AFL src

# Comunity version
# git clone https://github.com/vanhauser-thc/AFLplusplus.git
# wget https://github.com/AFLplusplus/AFLplusplus/archive/master.zip


unzip master.zip
mv AFLplusplus-master src

cd src
 
# Checkout target version
#git checkout remotes/origin/stable


# Set library path to include glibc-static
TLB_GLIBC_STATIC="${HS_ROOT}/0.TLB/glibc-static/usr/lib64"

## # LLVM DEPENDENCY
## LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/${TLB_GLIBC_STATIC}
## export LD_LIBRARY_PATH=$LD_LIBRARY_PATH


# Compile and install AFL follow standar stucture name
#make distrib STATIC=1 # It's ok but some crashes are not capture
make distrib STATIC=1 AFL_HARDEN=1 ASAN_BUILD=1 # Harden: Better with stdin binaries/libraries ASAN: Improve memory control


## # TODO: Full LLVM Support and LTO, maybe adding unicorn or qemu
## # DISABLE LLVM, resolve dependencies and standalone it's not trivial such as based on gcc g++
## cd llvm_mode
## # LLVM no i686 error downgrade to gcc
## make LD_LIBRARY_PATH="$LD_LIBRARY_PATH" STATIC=1 AFL_NO_X86=1 LLVM_CONFIG=llvm-config-11 
## cd ..

mkdir ${_basePath}/files
make install DESTDIR=${_basePath}/files
# WORKAROUND:# To installa afl-as under AFL_PATH
find . -maxdepth 1 -type f -exec test -x {} \; -exec cp {} "../files/usr/local/bin/" \;

