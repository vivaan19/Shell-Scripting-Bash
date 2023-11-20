#!/bin/bash 

##### Arrays #####


# Syntax :: 

# initialize : MY_ARRAY=(1 2 3 4)

# to access : ${MY_ARRAY[@]} --> @ means all items ; also put indexes 

MY_ARRAY=(one two three 1) 

echo ${MY_ARRAY[4]}
