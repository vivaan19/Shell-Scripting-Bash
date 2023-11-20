#!/bin/bash 

#### IF ELIF ELSE #### 
## Program to check if the positional argument is correct ## 
# here inside test operator is expansion parameters which are used to ignore case sensitivity 

if [ ${1,,} = vivaan ]; then 
	echo "Hello Vivaan"

elif [ ${1,,} = help ]; then 
	echo "Enter username"

else
	echo "Invalid username"

fi
