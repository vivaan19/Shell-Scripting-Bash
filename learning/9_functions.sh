#!/bin/bash 

##### Script to get uptime and since when machine is on using functions #### 
## and also converting date into dd-mm-yyyy format

## Local is a keyword which is used to define that the variables are local to the function
## it bascially means that the value of variable will not get overwritten 

displayUpTime(){
	
	local up=$(uptime -p | cut -c 4-)

	local since_date=$(uptime -s | cut -c 1-10 | awk -F- '{printf("%02d-%2d-%4d\n",$3,$2,$1)}')

	local since_time=$(uptime -s | cut -c 12-)
	
	cat << EOF

	------------------------------------ 
	
	The machine has uptime of ${up} 
	and active since date-${since_date} time-${since_time}
	
	------------------------------------
EOF

}
displayUpTime
