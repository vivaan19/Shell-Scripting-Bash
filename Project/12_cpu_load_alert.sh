#!/bin/bash 

#############################################################################
# This script is used to alert the user if the load average is greater than 1
#############################################################################

cat << EOF

    ####################################
    Welcome $(whoami) to cpu load alert
    ####################################

EOF

LOAD_AVG_VAL_1=$(top -bn1 | grep load | awk -F"  " '{print $3}' | awk -F": " '{print $2}' | awk -F', ' '{print $1}')

if [[ $(echo "$LOAD_AVG_VAL_1 > 1" | bc) -eq 1 ]]; then


    echo "WARNING: LOAD AVERAGE IS GREATER THAN 1"
    exit 1

else
    echo "SYSTEM LOAD AVERAGE FINE"
    exit 0
fi

