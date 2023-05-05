# Load WLP context variables
source target.conf

echo "DEBUG: $0 $1"

# Local script variables
_JOB=$1

# Set master fuzzer Name
if [ -f "masterfuzzer.name" ]; then
   # Recover previous name 
    _fuzzerName="$(cat masterfuzzer.name)"  
fi

# Obtaine previos master fuzzer state
_JB_MF_ID="$(cat masterfuzzer.name | cut -c3-)"
_JB_MF_STATE="$(squeue --noheader | grep $_JB_MF_ID)"

if [ -z "$_JB_MF_STATE" ]; then 
  _MF_IS_ALIVE=0
  rm masterfuzzer.name -rf
else
 _MF_IS_ALIVE=1
fi

#echo "DEBUG: _JB_MF_ID=$_JB_MF_ID"
#echo "DEBUG: _JOB=$_JOB"
#echo "DEBUG: _JB_MF_STATE=$_JB_MF_STATE"
#echo "DEBUG: _MF_IS_ALIVE=$_MF_IS_ALIVE"
#echo "DEBUG: _fuzzerName=$_fuzzerName"

if (($_MF_IS_ALIVE)); then

    # YES, IT'S ALIVE
    echo "ERROR: A master fuzzer $_fuzzerName was detected."

else

    # NO, IT'S ALIVE



    if [ -n "$_fuzzerName" ]; then 
      _oldFuzzerName=$_fuzzerName
    fi

    # Use a new  fuzzerName
    _fuzzerName="MF${_JOB}"
    echo ${_fuzzerName} > masterfuzzer.name

    echo "DEBUG: _fuzzerName=$_fuzzerName _oldFuzzerName=$_oldFuzzerName"

    # Get basedir
    _PWD=$(pwd)

    # Copy prepared binary
    cp $_bin ${_PWD}/bin/ -r


    #TODO: Embebidas en linea con el comando no las coge ...
        # Set default compilers and AFL_PATH (for afl-gcc, the var change between afl-gcc and afl-fuzz)
        #export CC="$HS_CC"
        #export CCX="$HS_CCX"
        #export AFL_PATH="$TLB_AFL_PATH_COMPILE"
        #export AFL_PATH="$TLB_AFL_PATH_FUZZ"

        # Add custom auxiliar binaries to enviroment PATH
        #export PATH=${PATH}:${HS_ROOT}/0.TLB/_bin_

        # Add custom auxiliar binaries to enviromente PATH
        #export PATH=${PATH}:${AFL_PATH}

        #echo "DEBUG: AFL_PATH=$AFL_PATH"
        #echo "DEBUG: PATH=${PATH}"

    # Set compiler and compile
    #TODO: Probar a cambiar init de bash para inicio limipip
    #bash --noprofile --norc -x -c "afl-gcc ./src/$_target -o $_out"


    if [ -d "$_out" ]; then
      # TODO: Comprobar bug sinconizacion de directorios AFL++ vs scayle: PROGRAM ABORT : Resume attempted but old output directory not found
      echo "DEBUG: Recover task $_out" 
     # Recover task 
      env AFL_PATH="$TLB_AFL_PATH_FUZZ" AFL_NO_AFFINITY=1 AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ${TLB_AFL_PATH_BIN}/afl-fuzz -i - -o $_out -M $_fuzzerName ${_PWD}/bin/${_target} ${_param}
    else
      echo "DEBUG: New task $_out" 
      mkdir -p $_out
      # New task
      env AFL_PATH="$TLB_AFL_PATH_FUZZ" AFL_NO_AFFINITY=1 AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ${TLB_AFL_PATH_BIN}/afl-fuzz -i $_in -o $_out -M  $_fuzzerName ${_PWD}/bin/${_target} ${_param}

    fi

  # TODO: Comprobar coredumps no sature o pete algo
  # [-] Hmm, your system is configured to send core dump notifications to an      
  #     external utility. This will cause issues: there will be an extended delay 
  #     between stumbling upon a crash and having this information relayed to the 
  #     fuzzer via the standard waitpid() API.                                    
  #     If you're just testing, set 'AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1'.    
  #                                                                               
  #     To avoid having crashes misinterpreted as timeouts, please log in as root 
  #     and temporarily modify /proc/sys/kernel/core_pattern, like so:            
  #                                                                               
  #     echo core >/proc/sys/kernel/core_pattern
fi