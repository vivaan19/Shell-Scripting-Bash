#!/bin/bash 

##############################################################
# Monitor disk usage for 2 minutes and store that in log file 
# this script can be involved in a service file 
# service file contains:: 
#   1. Unit section : description, documentation and details 
#   2. Service section : username, group, service type, what to do in failure, restart timeout ExecStart - provides the program what to run 
#       ExecStartPre : used to define anything before the script 
#       SysLogIdentifier : Define the service in service log 
##############################################################

while [ True ]; do 

    

    sleep 120

done

