#!/bin/bash 

######################################################################################
# Bash script to list all the running service from /etc/ , /run , /lib systemd folders
# List the destination path and service name in $HOME/all_active_service.txt 
######################################################################################


# service name : systemctl status apache2 | awk 'NR==1' | awk -F" - " '{print $2}'

# service status : systemctl status apache2 | grep Active | awk -F": " '{print $2}' | awk -F" " '{print $1}'

# end variable
FILE_EXT="service"

# all active service path | with service name
DEST_FILE_PATH=${HOME}/all_active_service.txt

if [ $(wc -l < "${DEST_FILE_PATH}") -ne 0 ]; then

    echo "" > ${DEST_FILE_PATH}
fi


FILE_ARRAY=(etc run lib)

for i in ${FILE_ARRAY[@]}; do

	LST_FILE=$(ls /$i/systemd/system)

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

					echo -e "$j\t\t\t\t\t\t${SRV_NAME}" >> $DEST_FILE_PATH
					# echo -e "\n" >> $DEST_FILE_PATH
				fi
			fi
		fi
	done

done
