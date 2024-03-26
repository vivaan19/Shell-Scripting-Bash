#!/bin/bash 

##################################################################
# Author ::: Vivaan Shiromani 
# GitHib ::: Vivaan19 
# Date   ::: 26/03/2024 
# About  ::: MENU DRIVEN - PASSWORD GENERATOR BY VARIOUS METHODS 
###################################################################

# PASSWORD GENERATOR BY VARIOUS METHODS 
# INPUT PASSWORD LENGTH, NUMBER OF PASSWORD REQURIED and PASSWORD METHOD REQUIRED 

# NOTES ::: 
# default value of a variable if a variable is unset or null --- ${var:-<default_value>} - if val is set it will behave like ${var} if not then 
# <default_value>
# ::: 

#######################################################################
# Function used to check if value is empty and have Integer value 
# Args : $1 - 'd' or 'nd' : d means default validation of 2 parameters 
#                         : nd means non-default validation of 1 parameter
#      : $2, $3 - checking parameter 
##########################################################################
dataValidation() {

    # for defualt validation 
    if [ "$1" == "d" ]; then 

        # data validation for missing value 
        if [[ "$2" == "" ||  "$3" == "" ]]; then

        echo "ERROR: MISSING INPUT"
        exit 1

        fi

        # data validation for both-integer value using regex 
        # =~ is a regex match : ^ means starting [0-9]+ only digits can be more than 1 digit $ means ending with
        if [[ ! "$2" =~ ^[0-9]+$ || ! "$3" =~ ^[0-9]+$ ]]; then

            echo "ERROR: NON INTEGER VALUE"
            exit 1

        fi
    
    # for non-default validation  
    elif [ "$1" == "nd" ]; then
        
        if [[ ! "$2" =~ ^[1-3]$ ]]; then

            echo "ERROR: INVALID INPUT"
            exit 1

        fi
    
    fi

    # clear the screen for next instructions 
    clear

}

#########################################################################
# Function used to generate password based upon-selection method and number 
# Args : $1 - y or n - if passwd wants to be saved in a text file or not 
#      : $2 - Number of password 
#      : $3 - Length of password 
#      : $4 - Method of password 
#########################################################################
generatePasswd() {

    echo "Number of passwords - $2 ; Length of each password - $3" > passwd.txt
            
    echo "------------------------------------------------------------------------" >> passwd.txt
    
    for i in $(seq "$2"); do

        if [ "$4" -eq 1 ]; then
            echo "Password $i ---------  $(openssl rand -base64 48 | cut -c1-"$3") " 
        fi
        
        if [ "$4" -eq 2 ]; then
            echo "Password $i --------- $(openssl rand -hex 48 | cut -c1-"$3")" 
        fi

        if [ "$4" -eq 3 ]; then
            
            echo "Password $i --------- $(tr -cd "[:alnum:]" < /dev/urandom | fold -w"$3"| head -n 1)" 
        
        fi

    done >> passwd.txt ; 

    
    if [ "$1" == 'y' ]; then 
        
        echo "INFO: PASSWORD GENERATION COMPLETED"

        echo "PASSWORD FILE STORED AT: $(pwd)/passwd.txt"

    elif [ "$1" == 'n' ]; then
        
        echo "INFO: PASSWORD GENERATION COMPLETED"

        cat "$(pwd)"/passwd.txt

        rm "$(pwd)"/passwd.txt
    fi

}

echo "Welcome to random password generator"

echo 

read -r -p "Input password length: " PASS_LENGTH
read -r -p "Input number of password: " PASS_NO

echo 


dataValidation "d" "$PASS_LENGTH" "$PASS_NO"

# password generation methods 
cat << EOF 

######### CHOOSE WHICH TYPE OF PASSWORD TO GENERATE ###########

Press 1 : For OpenSSL Base64 format 
Press 2 : For OpenSSL Hex format 
Press 3 : For URandom (built-in linux library) format 

EOF


read -r -p "Enter Input : " PASS_METHOD

echo

######### OLD METHOD FOR VALIDATION #########

# data validation for input 
# making an array of inputs 
# INPUTS=("1" "2" "3")

# using sed command to trim any trailing and leading whitespaces 
# sed command : ^ this represents start of line whitespaces and $ means end of line * means all after // is the replacement
# PASS_METHOD=$(echo "$PASS_METHOD" | sed 's/^ *//;s/ *$//')
# checks if the supplied method is in the input array

##############################################

# Improved method 
dataValidation "nd" "$PASS_METHOD"

while true; do
   
   read -r -p "Want to store random generated passwords in a text file ? [Y]/[N]: " IS_STORE

   case $IS_STORE in

       [Yy]* ) 

            echo
            generatePasswd "y" "$PASS_NO" "$PASS_LENGTH" "$PASS_METHOD"
            break;;

        [Nn]* ) 

            echo
            generatePasswd "n" "$PASS_NO" "$PASS_LENGTH" "$PASS_METHOD"
            break;;

       * ) echo "Invalid input. Please enter Y/y or N/n.";;

   esac
done


echo "--------------------------------------------------------------------------"
echo "DONE"

