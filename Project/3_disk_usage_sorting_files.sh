#!/bin/bash 

################ Bash script to find the 10 biggest file in the file system and write output to a file in a nice format 

# Commad used here :: 

# du - disk usage 
    # -h flag : to have output in a human redable format lists only dir 
    # -a flag : list both file and dir 

# sort - to sort according to numbers 
    # -n flag (default) : used to sort by numeric values 
    # -r flag : prints the result in reverse order 
    # -h flag (default) : human redable format 

#############################################
# Display Message 
#############################################
cat << EOF

    ##############################################################
    Welcome $(whoami) to find 10 biggest files in the path entered 
    ##############################################################

EOF


#######################################################
# function to check the file path when user provides any 
#######################################################
checkFilePath() {
    
    is_file_err=$(file $path 2> /dev/null)  
	
	if [ $? = 0 ]; then	
	
		is_file=$(file $path | awk -F: '{print($2)}' | cut -c2-)
		
		if [ "${is_file}" = "directory" ]; then
			return 0
	
		else
			return 1
	
		fi

    # if exit code is 1
	else
		echo "Incorrect path"
		exit 1
	fi
}

read -p "Enter file path ::: " path

checkFilePath $path

if [ $? == 0 ]; then

    # logic 
    # 1. Use du -ha command to have output in human redable format + iterate through all files in a dir 
    # 2. Use sort -hr commad to sort the output in numeric increasing order 
    # 3. Use output redirection to store the content in a text file 

    # these are the file contents with size and file path name excluding the first name
    FILE_CONTENT=$(du -ha ${path} | sort -hr | awk "NR>1")

    # total size of path
    TOTAL_SIZE=$(du -ha ${path} | sort -hr | awk "NR==1"| awk '{print $1}')

    echo Total size : ${TOTAL_SIZE}

    ECHO=$(echo)

    echo File contents of the path entered ::

    cat <<< "${FILE_CONTENT}" > sample.txt

    cat sample.txt

else 
    echo Incorrect path
    exit 1
fi