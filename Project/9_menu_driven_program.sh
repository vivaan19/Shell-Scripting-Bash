#!/bin/bash 

################################
# Menu driven program
# calculator which has 4 options 
# 1. Add, 2. Sub, 3. Mul, 4. Div 
################################

#######################
# DISPLAY MESSAGE 
#######################
cat << EOF 

    ######################################
        Welcome $(whoami) to calculator
    ######################################

EOF

echo "Enter Relevant message :: "

echo -e " [a] addition \n [b] substraction \n [c] multiplication \n [d] division"

read -p "Input your command : " ANSWER


