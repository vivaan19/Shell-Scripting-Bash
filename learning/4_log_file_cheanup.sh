#!/bin/bash 

#############################################################################################################################
# Chenup the log files 
# log rotation 
# Write a script to cleanup the logs as per the number of days 
# find - used to find files as per name, file location, dir location, creation date, modification date, owner and permission 
	# flag -mtime - modifiled timestamp - indicates the last time content of a file were modified  
    	# flags - +n ; -n ; n 

# for ex: mtime +30 -> get the files greater than 30 days ; means for example today is 29th Jan so it will fetch files from december that date
# as the difference

# find /path/to/logs -name "*.log" -mtime +30 -delete

# /path/to/logs: Replace this with the actual path to your log files directory.
# -name "*.log": Specifies that you want to operate on files with a .log extension. Adjust this pattern to match your log file names.
# -mtime +30: Specifies files that were modified more than 30 days ago.
# -delete: Directly deletes the files that match the criteria.
#############################################################################################################################