#!/bin/bash

####################################################
# read 
	# flags 
	# -p : to prompt 
	# -t : to have input opened for a x secs 
	# -s : to silent the input 
	# -a : pass the input as in array 
	# -d : delimeter the input to any delimeter 
	# -e : starts the interactive shell 
	# -r : disable backslash to escape charater 
#####################################################

read -p "Your name? " name

echo $name 

read -p "Password? " -s password 

echo $password 

echo

read -p "Input for 4 sec " -t 4 input 

echo $input

read -a arr 

# echo $arr
echo ${arr[@]}

for i in ${arr[@]}; do

	echo $i
done
