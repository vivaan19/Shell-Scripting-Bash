#!/bin/bash 

#####################################################
# Script to check if the URL has a status code of 200
#####################################################


########################################
# Display Message
########################################
cat << EOF

	#############################################
	Welcome $(whoami) to http status code checker
	Connection timeout secounds - 10
	#############################################
EOF


####################
# Read input URL
####################
read -p "Enter full URL with http: " URL 

##############################################################
# Check if URL is invalid or takes more than 10 sec to respond
##############################################################
curl --silent -m 10 $URL >> /dev/null

if [ $? -ne 0 ]; then
	echo "ERROR: Invalid URL or Connection timed out"
	exit 1
fi

################################
# Extracting HTTP Status code 
################################
HTTP_STATUS_CODE=$(curl --silent --include $URL | awk "NR==1" | cut -d " " -f2)


#############################################
# Checking if the status code is equal to 200
#############################################
if [ $HTTP_STATUS_CODE -eq 200 ]; then 

	echo "SUCCESS: STATUS CODE 200"
	exit 0

else 
	echo "ERROR: INVALID ERROR CODE"
	echo "ERROR CODE: $HTTP_STATUS_CODE"
	exit 1

fi


