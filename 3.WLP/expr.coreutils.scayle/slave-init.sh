# Load WLP context variables
source target.conf

echo "DEBUG: $0 $1"

# Local script variables
_JOB=$1
_fuzzerName="SF${_JOB}"

echo "DEBUG: _fuzzerName $_fuzzerName" 

# Check for master fuzzer existance
if [ -f "masterfuzzer.name" ]; then
  echo "DEBUG: New task $_out" 
  mkdir -p $_out
  # New slave task
  env AFL_PATH="$TLB_AFL_PATH_FUZZ" AFL_NO_AFFINITY=1 AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ${TLB_AFL_PATH_BIN}/afl-fuzz -i $_in -o $_out -S $_fuzzerName ./bin/${_target} $_param

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
else
  echo "ERROR: No master fuzzer was detected."
fi