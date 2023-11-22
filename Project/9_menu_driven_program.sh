#!/bin/bash 

################################
# Menu driven program
# calculator which has 4 options 
# 1. Add, 2. Sub, 3. Mul, 4. Div 
################################

#######################
# DISPLAY MESSAGE 
#######################

clear

cat << EOF 

    ######################################
        Welcome $(whoami) to calculator
    ######################################

EOF

###############################
# Function to return two number 
##############################

return_two_num(){
	
	read -p "Input number-1: " num1

	read -p "Input number-2: " num2 
	
	echo

	if [ -z $num1 ]; then
		echo "Error: Blank Number Input"
		exit 1
	fi

	if [ -z $num2 ]; then 
		echo "Error: Blank Number Input"
		exit 1
	fi
	
	if [[ "$num1" =~ ^[0-9]+$ || "$num1" =~ ^[-][0-9]+$  &&  "$num2" =~ ^[0-9]+$ || "$num2" =~ ^[-][0-9]+$  ]]; then

		echo "Input Succesfull: Performing operations .... "
	else
		echo "Invalid Input: Exiting ... "
		exit 1
	fi

}


echo "Enter Relevant message :: "

echo -e " [a] addition \n [b] substraction \n [c] multiplication \n [d] division"

echo

read -p "Input your command : " ANSWER

echo

#########################
# Check for missing input
#########################

if [ -z $ANSWER ]; then

	echo "ERROR: Missing Input"
	exit 1
fi

case $ANSWER in
	[aA])
		#echo "In addition"
		return_two_num
		
		echo "Success: Addition of ${num1} and ${num2} is $(( ${num1} + ${num2}  ))"
		;;
	[bB])
		return_two_num

                echo "Success: Substraction of ${num1} and ${num2} is $(( ${num2} - ${num1}  ))"
                ;;
	[cC])
                return_two_num

                echo "Success: Multiplication of ${num1} and ${num2} is $(( ${num1} * ${num2}  ))"
                ;;
	
	[dD])
                return_two_num

		if [ ${num2} -eq 0 ]; then
			echo "ERROR: Zero Division"
			exit 1
		fi

		result=$(printf "%.2f" $((${num1} / ${num2})))

                echo "Success: Division of ${num1} and ${num2} is ${result}"

                ;;
	*)

		echo "Error: Wrong Input"
		
	esac
