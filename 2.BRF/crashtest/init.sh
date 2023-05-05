# Load context variables
source target.conf

# Copy prepared code
cp $_in $_src -r

# Set default compilers and AFL_PATH (for afl-gcc, the var change between afl-gcc and afl-fuzz)
export CC="$HS_CC"
export CCX="$HS_CCX"
export AFL_PATH="$TLB_AFL_PATH_COMPILE"

# Add custom auxiliar binaries to enviroment PATH
export PATH=${PATH}:${HS_ROOT}/0.TLB/_bin_

# Add custom auxiliar binaries to enviromente PATH
export PATH=${PATH}:${AFL_PATH}

#echo "DEBUG: AFL_PATH=$AFL_PATH"
#echo "DEBUG: PATH=${PATH}"

# Set compiler and compile
#TODO: Probar a cambiar init de bash para inicio limipip
#bash --noprofile --norc -x -c "afl-gcc ./src/$_target -o $_out"

env AFL_PATH="$TLB_AFL_PATH_COMPILE" $HS_CC $_src -o $_out


