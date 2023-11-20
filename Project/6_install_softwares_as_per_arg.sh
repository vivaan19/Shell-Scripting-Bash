#!/bin/bash 

############################################################################################

# This is a script to install software as passed to command line arguments 

# First it will check if the argument passed is greater than 0 

# Then it will check if the user id is 0 that is root user 

# Then it will check if that software is already present if yes then do not install if not then install 

########################################################################################################

#####

# $# used to get how many argument is passed 

# $@ used to get a list of argument values ; it can be iterated in the for loop 

##### 


#############################################

# Checking if the argument is greater than 0 

############################################

if [ $# -eq 0 ]; then 
        
	echo "Zero argument passes"
        exit 1
fi	

################################

# Checking the user is root user 

###############################


if [ $(id -u) -ne 0 ]; then
	
	echo "Install the software with root user"
	exit 2
fi

################################

# install the software ; if they are not present ; otherwise print the message if it exists ; or if the software name is gibbrish just ignore it  

###############################


for software in $@; do

	which $software &> /dev/null

	if [ $? -eq 0 ]; then 

		echo $software is already installed 
	
	else
		sudo apt install $software -y &> /dev/null

		if [ $? -eq 0 ]; then

			echo $software installed successfully

		else
			echo $software --- Invalid !!! 
		
		fi
	
	fi
done



