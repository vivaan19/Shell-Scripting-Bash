#!/bin/bash 

#######################################
# Script to take backup of Directories 
#######################################

# Backup Destination location - root/backup/<Today's date with time stamp>
# Backup file name - Screenshot - <screenshot>/<today's date>.tar.gz ; Desktop - <desktop>/<today's date>.tar.gz

# Algorithm :
#
# 0. Make destination directory 
# 1. Iterate through directories specified inside array  
# 2. tar zip directories with specified name with tar.gz extension 
# 3. copy all the directories in tmp folder 
# 4. Copy all the tar.gz inside tmp folder to destination folder


cat << EOF

    ########################################
    Welcome $(whoami) to script to take backup
    of directories of Screenshots and Desktop 
    ########################################

EOF

###############################################################################
# Make backup directory - location - root/backup/<today's date with timestamp>
###############################################################################


if [ $(id -u) -ne 0 ]; then
	
	echo "Install the software with root user"
	exit 2
fi

# /root/backup/<time> 
DEST_DIC_TIME=$(date +%d_%m_%Y_%H_%M_%S)
DEST_LOC=/root/backup/${DEST_DIC_TIME}

# backup date
TODAY_DATE=$(date +%d_%m_%Y)

# dirs for backup
DIRS=("/home/vivaanbd/Pictures/Screenshots" "/home/vivaanbd/Desktop")

mkdir -p $DEST_LOC

echo Taking Backup of folders ${DIRS[@]}

for dirs in ${DIRS[@]}; do

    # here to extract name - we are first reversing the path then using cut extract first field and then reverse it again
    name=$(rev <<< "$dirs" | cut -d '/' -f1 | rev)

    BACK_LOC=/tmp/${name}_$TODAY_DATE.tar.gz

    sudo tar -Pczf $BACK_LOC $dirs

    if [ $? -eq 0 ]; then 
        echo "Backup Done at location :: $BACK_LOC"
        echo
    else
        echo "Backup Had some problems .... "
        echo
    fi

    # Copy the files to destination folder 

    cp $BACK_LOC $DEST_LOC

    if [ $? -eq 0 ]; then
        echo $dirs has been backuped successfully 
        echo
        echo Destination Location - $DEST_LOC
    else
        echo "Backup not successfull"
        echo
    fi
done

sudo rm -rf /tmp/*.gz

echo "Backup done ...... "



