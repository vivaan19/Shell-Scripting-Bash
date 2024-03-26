#!/bin/bash 

###################################
# AUTHOR ::: VIVAAN SHIROMANI
# DATE   ::: 26/04/2024  
###################################

# ABOUT  ::: 
######################################################################################
# Bash script to list all the running service from / systemd folders then
# List the destination path and service name in $HOME/all_active_service.txt 
######################################################################################


# Notes :::: 
# service name : systemctl status apache2 | awk 'NR==1' | awk -F" - " '{print $2}'
# service status : systemctl status apache2 | grep Active | awk -F": " '{print $2}' | awk -F" " '{print $1}'
# :::: 

# service file extension 
FILE_EXT="service"

# all active service path | with service name
DEST_FILE_PATH=${HOME}/all_active_service.txt

#####################################################################
# This function is used to validate arguments passed
# Args : $1 - total number of arguments - if 0 args then give Error  
######################################################################
validations() {

	if [ "$1" -eq 0 ]; then 

		echo "ERROR: No Argument Passed"
		exit 1

	fi

	if [ ! -f "$2" ]; then 
		
		touch "$DEST_FILE_PATH"
	
	else

		# If the file has any data (or lines) empty it for initialization
		if [ "$(wc -l < "$2")" -ne 0 ]; then

			echo "" > "$2"
		fi

	fi

}

# $# is used to send number of arguments 
validations $# "$DEST_FILE_PATH"


##################################################################################################
# This function is used to check the service status of the service to be active inside a directory 
# Arguments : $1 - / Directory name 
###################################################################################################
serviceChecker() {

	# check if systemd file exist if no then skip the directory 
	DIR_PATH="/$1/systemd/system"

	if [ -d "$DIR_PATH" ]; then 

		LST_FILE=$(ls "$DIR_PATH")

		echo "-------------------------------------------------------------------------------------" >> "$DEST_FILE_PATH"
		
		for j in $LST_FILE; do

			# reverses the file name and extracts the name after . 
			EXT_EXTRACT=$(echo $j | rev | cut -d "." -f1 | rev)

			if [ "${EXT_EXTRACT}" == $FILE_EXT ]; then

				# check if systemctl returned with exit code of 0
				systemctl status $j &> /dev/null

				if [ $? -eq 0 ]; then
					
					# checkes the service status as active 
					SRV_STATUS=$(systemctl status $j | grep Active | awk -F": " '{print $2}' | awk -F" " '{print $1}')

					if [[ "${SRV_STATUS}" == "active" && $? -eq 0 ]]; then

						# extract the name of the service 
						SRV_NAME=$(systemctl status $j | awk 'NR==1' | awk -F" - " '{print $2}')

						echo -e "$DIR_PATH/$j\t\t\t\t\t\t${SRV_NAME}" >> "$DEST_FILE_PATH"

					fi
				fi
			fi

		done
	
		echo "-------------------------------------------------------------------------------------" >> "$DEST_FILE_PATH"
	
		echo "DONE For Directory $i" 
	
	else

		echo "$DIR_PATH does not exist"

	fi


}

FILE_ARRAY=("$@")	

for i in "${FILE_ARRAY[@]}"; do

	serviceChecker "$i"
	
done

