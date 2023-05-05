# Load WLP context variables
source target.conf

# disable bash debug
set -x

if [ -d "$_out" ]; then
  # Active task 
 #watch -c -n 30  env AFL_PATH="$TLB_AFL_PATH_FUZZ" AFL_NO_AFFINITY=1 AFL_I_DONT_CARE_ABOUT_MISSING_CRASHES=1 ${TLB_AFL_PATH_BIN}/afl-whatsup -s $_out
 ${HS_ROOT}/0.TLB/_HOUSE_/afl-slurm-stats $_out
else
  # Non data
  echo "No active task." 

fi
