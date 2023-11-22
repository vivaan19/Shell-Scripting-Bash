#!/bin/bash 

##############################################################
# script for sed command 
# Display Commands for sed  
#   - sed '' <file_name> --> used to display all the things 
#   - sed 'p' <file_name> --> this will print the lines twice 
#   - sed -n 'p' <file_name> --> this will print lines only once 
#   - sed -n '$p' <file_name> --> this will print last line of file 
#   - sed -n '3, 10p' <file_name> --> this will display lines from 3rd to 10 lines
#   - sed '10d' <file_name>  --> while displaying lines delete 10th line 
#   - sed -I '2,10d' <file_name>  --> delete the original file
#   - sed -i.back '2,10d' <file_name>  --> this will take backup before delele the file in original file 

# Find and replace 
#   - sed 's/<word_to_replace>/<word_to_be_replaced>' <file_name> ---> it will replace the first occurance of word

#   - sed 's/<word_to_replace>/<word_to_be_replaced>/g' <file_name> ---> it will replace all the words globally

#   - sed i.back 's/<word_to_replace>/<word_to_be_replaced>/g' <file_name> ---> will change in original file also after taking a backup

#   - sed '/search_keyword/s/<word_to_replace>/<word_to_be_replaced>' <file_name>  ---> 
#       this will search the file based upon a search keyword then the word will be replaced it can be done globally as well as first occurance

# Insertion and deletion with sed command 
#   - sed '<line_number>i <to_insert>' <file_name> ---> this command will insert a line before line_number with content <to_insert> 
#       i option is used to add before a particular line 
#
#   - sed '<line_number>a <to_insert>' <file_name>  ---> this command will insert a line after line_number with content to_insert
#       a option is used to add add a line after  
#################################################################

cat << EOF > sed_file.txt
The ssh-keygen command is a component of most SSH implementations used to 
generate a public key pair for use when authenticating with a remote server. 
In the typical use case, users generate a new public key and then copy their 
public key to the server using SSH and their login credentials 
for the remote server.
EOF

