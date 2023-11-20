#!/bin/bash 

# case statements are used when checking multiple input values together 

# syntax :: 

# case <expression> in 
#                   abc) 
#                   <if that expression is equal to abc the execute this>
#		    ;; 
#		    *) 
#		    <if anything is supplied in the input then do this>
#		

# *) this is the catch all expression means that what ever will be supplied in the input it will deal here

case ${1,,} in 

	vivaan | admin | administrator)
		
		echo Hello ${1,,}
		;;
	
	help)
		echo Enter proper username 
		;;
	
	*)
		echo Invalid username
esac 
