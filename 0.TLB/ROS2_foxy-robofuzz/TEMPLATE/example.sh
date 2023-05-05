#!/bin/bash

# This script run inside CONTAINER.
# Script example
# Usage: example.sh arg1 arg2 arg3

#Debbuging
#set -x                 # activate debugging from here
set +x # desactivate debugging from here

HS_IDNUM="$(cat /tmp/value/IDNUM)" # Read IDNUM from file generate by singularity-init.sh in prerun stage.

echo "$HS_IDNUM is the value IDNUM, unique value based on EPOCH or slurm JOB ID to use as unique run identificator value accross host and container."
echo "----"

echo "Arguments $*"
