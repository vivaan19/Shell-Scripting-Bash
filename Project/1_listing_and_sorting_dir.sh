#!/bin/bash 

########## This bash scripts accepts directory path and lists the files inside that in a more nicer way 


checkIfDir(){
	

	is_file_err=$(file $1 2> /dev/null)  
	
	if [ $? = 0 ]; then	
	
		is_file=$(file $1 | awk -F: '{print($2)}' | cut -c2-)
		
		if [ "${is_file}" = "directory" ]; then
			return 0
	
		else
			return 1
	
		fi
	else
		echo "Incorrect path"
		exit 1
	fi

}

checkIfDir $1

if [ $? = 0 ]; then
	
	dir_content=$(ls $1)
	
	for item in ${dir_content}; do
		
		echo
		echo $item
	done
else 
	echo Invalid path
	exit 1
fi
