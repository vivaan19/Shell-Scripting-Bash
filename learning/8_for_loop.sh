#!/bin/bash 

# LOOPS #

ARR=(cat dog pet)

for item in ${ARR[@]}; do
	
	val=$(wc -c <<< $item);

	#echo "Item name $item has word count of ${val}"
	#echo -n $item | wc -c;
done
