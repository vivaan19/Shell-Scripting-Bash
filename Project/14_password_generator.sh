#!/bin/bash 

# password generator by various methods 
# input Password length and number of password requried
# default value of a variable if a variable is unset or null --- ${var:-<default_value>} - if val is set it will behave like ${var} if not then 
# <default_value>

echo "Welcome to random password generator"

echo 

read -p "Input password length: " PASS_LENGTH
read -p "Input number of password: " PASS_NO

echo 

# data validation

if [[ "$PASS_LENGTH" == "" ||  "$PASS_NO" == "" ]]; then

    echo "ERROR: MISSING INPUT"
    exit 1

fi

expr $PASS_LENGTH + $PASS_NO &> /dev/null

if [ $? != 0 ]; then

    echo "ERROR: NON INTEGER VALUE"
    exit 1

fi


# password generation methods 

cat << EOF 

Press 1 : For OpenSSL Base64 format 
Press 2 : For OpenSSL Hex format 
Press 3 : For URandom (built-in linux library) format 

EOF


read -p "Enter Input : " PASS_METHOD

echo

# data validation for input 
# making an array of inputs 
INPUTS=("1" "2" "3")

# using sed command to trim any trailing and leading whitespaces 
# sed command : ^ this represents start of line whitespaces and $ means end of line * means all after // is the replacement
PASS_METHOD=$(echo $PASS_METHOD | sed 's/^ *//;s/ *$//')

# checks if the supplied method is in the input array
if [[ ! " ${INPUTS[@]} " =~ " ${PASS_METHOD} " ]]; then

    echo "ERROR: INVALID INPUT"
    exit 1

fi


while true; do
    read -p "Want to store random generated passwords in a text file ? [Y]/[N]: " IS_STORE

   case $IS_STORE in

       [Yy]* ) 

            echo "Number of passwords - $PASS_NO ; Length of each password - $PASS_LENGTH" > passwd.txt
            
            echo "------------------------------------------------------------------------" >> passwd.txt

            for i in $(seq $PASS_NO); do

                if [ "$PASS_METHOD" == "1" ]; then
                    openssl rand -base64 48 | cut -c1-$PASS_LENGTH
                fi
                
                if [ "$PASS_METHOD" == "2" ]; then
                    openssl rand -hex 48 | cut -c1-$PASS_LENGTH
                fi

                
                if [ "$PASS_METHOD" == "3" ]; then
                    
                    tr -cd [:alnum:] < /dev/urandom | fold -w$PASS_LENGTH | head -n 1
                fi

            done >> passwd.txt ; break;;

        [Nn]* ) 

            echo "Number of passwords - $PASS_NO ; Length of each password - $PASS_LENGTH" 
            
            echo "------------------------------------------------------------------------"            

            for i in $(seq $PASS_NO); do

                if [ "$PASS_METHOD" == "1" ]; then
                    openssl rand -base64 48 | cut -c1-$PASS_LENGTH
                fi
                
                if [ "$PASS_METHOD" == "2" ]; then
                    openssl rand -hex 48 | cut -c1-$PASS_LENGTH
                fi

                
                if [ "$PASS_METHOD" == "3" ]; then
                    
                    tr -cd [:alnum:] < /dev/urandom | fold -w$PASS_LENGTH | head -n 1
                fi 
            done; break;;

       * ) echo "Invalid input. Please enter Y/y or N/n.";;

   esac
done


echo "--------------------------------------------------------------------------"
echo "DONE"