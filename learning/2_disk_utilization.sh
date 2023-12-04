#!/bin/bash

###### DISK UTILIZATION - THIS SCRIPT ALERTS THE USER WHEN USED DISK OF A INPUTTED FILE SYSTEM WHICH IS MOUNTED ON A PARTICULAR LOCATION #####

# ALGO : 
# 1. GIVE USER HELP DETAILS - MAP THE MOUNTED FILE SYSTEM AS NUMBERS  
# 2. INPUT THE NUMBER WHICH MAPS TO MOUNTED FILE SYSTEM 
# 3. CHECK IF THE DISK UTILIZATION IS GREATER THAN 80% IF YES GIVE MESSAGE OTHERWISE EVERY THING OK MESSAGE 


####################
# Display message 
####################

cat << EOF
	
	###################################################################################
	
	WELCOME $(whoami) to DISK-UTILIZATION
	ENTER CHECK NUMBER TO CHECK DISK-UTILIZATION OF A PARTICULAR FILE SYSTEM MOUNTED ON
	
	###################################################################################
EOF

###################################################################
# Function to check if the provided mount system has usage above 80%
# Accessing array by input provided 
# awk 'NR==1' will extract only one record from grep output
###################################################################
checkMountSystem() {

	#echo File system :: ${FILE_SYSTEM[$1]} Mount at :: ${MOUNT[$1]}

	usage_level=$(df -h | grep -w ${MOUNT[$1]} | awk 'NR==1' | awk '{print $5}' | cut -d "%" -f1)

	#echo Usage Level :: $usage_level

	if [ $usage_level -lt 80 ]; then
		echo "Usage level is below 80%"
	elif [ $usage_level -gt 80 ]; then
		echo "Usage level is higher than 80%"
	else
		echo "Something went wrong"
	fi

}


##################################
# Array declaration 
##################################
declare -a FILE_SYSTEM=()
declare -a MOUNT=()

#####################################
# Adding items to file system and mount array 
######################################
for item in $(df -h | awk '{print $6}'); do
	MOUNT+=("$item")
done

for item in $(df -h | awk '{print $1}'); do
	FILE_SYSTEM+=("$item")
done

#############################################
# To Display which are the file system mounted at and corresponding check number 
#############################################
cat << EOF
	
	FILE SYSTEM ------------ MOUNT AT ------------ CHECK NUMBER

EOF

for j in $(seq 1 ${#MOUNT[@]}); do
	
	if [ $j -eq 8 ]; then
		cat <<< ""

	else
cat << EOF 
	${FILE_SYSTEM[$j]} ------------ ${MOUNT[$j]} ------------ $j
EOF
	fi

done


########################################################################
# Reading input from the user about check number 
# Data validation also happening 
# If Input is valid it goes to function where it does further operations 
#########################################################################
read -p "Enter check number : " answer

if [[ "$answer" == "" ]]
then
    echo "Input is missing."
    exit 1
fi

if [[ "$answer" =~ ^[0-9]+$ || "$answer" =~ ^[-][0-9]+$  ]]; then

	if [ $answer -ge 1  ] && [ $answer -le $((${#MOUNT[@]}-1)) ]; then 
		
		checkMountSystem $answer  

	else 
		echo not valid
	fi
else
	echo not valid

fi


######################### END OF SCRIPT ###################################



