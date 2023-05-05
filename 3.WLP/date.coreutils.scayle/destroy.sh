# Load WLP context variables
source target.conf

# disable bash debug
set +x

# Cancel all jobs
if [ -f "jobs.lst" ]; then
    echo "Cancelling jobs ..."
    for JB in $(cat jobs.lst); do scancel $JB;done
    rm jobs.lst
fi

# Remote all context data
if [ -d "$_out" ]; then
    echo "WARNING: All workload package output data will be deleted. This may cause loss of results or prevent to continue previous jobs."
    read -p "Are you sure to remove all data related with this WLP in OR repository? " -n 1 -r
    echo    
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
       # Remove output repository
        rm $_out -rf
       # Remove master fuzzer reference
        rm masterfuzzer.name -rf
    fi
fi
