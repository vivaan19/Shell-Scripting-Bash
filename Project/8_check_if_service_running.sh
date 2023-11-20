#!/bin/bash 

######################################################################

# A bash script to first check if the entered name is valid service 

# if valid it will check the status of service 

# if service is active ; it will prompt to stop the service or not ; if yes then service will be stopped ; if not then service will be as running 

# if service is inactive ; it will prompt to start the service or not ; same logic 

####################################################################################################################################################


cat << EOF

	################################
	Welcome $(whoami) to the script
	################################
EOF


#########################
# service_on_off function
#########################
service_on_off(){
	
       	read -p "Do you want to $2 the service (Y/N) " ANS

	case $ANS in 
		[Yy])
            
	    		echo "Service is now going to be $2 ...... "
            		systemctl $3 $1 &> /dev/null

            		if [ $? -eq 0 ]; then
                		echo "Success: Service successfully $2 ...."
                		systemctl status $1
                		exit 0
            		
			else
                		echo "Error: Something went wrong"
				exit 1
			
			fi

			;;

		[Nn])
			echo "Service is running fine .... No changes done"
			exit 0
			;;
		*)

			echo "Invalid Input"
			exit 1
	esac

	
}


read -p "Enter a valid service name : " SERVICE_NAME

if [ -z $SERVICE_NAME ]; then 

	echo "Error: Service field is blank"
	exit 1
fi

ls /var/run/$SERVICE_NAME &> /dev/null

if [ $? -ne 0 ]; then 

	echo "Error: Invalid Service name"
	exit 1
else
	SERVICE_STATUS=$(systemctl status $SERVICE_NAME | grep -w  Active | cut -d ':' -f2 | cut -d " " -f2)
	
	echo "Service name - $SERVICE_NAME status is #### ${SERVICE_STATUS} ####"

	if [ "${SERVICE_STATUS}" = "active" ]; then 

		service_on_off $SERVICE_NAME deactivate stop
	
	elif [ "${SERVICE_STATUS}" = "inactive" ]; then
	       	
		service_on_off $SERVICE_NAME activate start
	
	fi

fi

