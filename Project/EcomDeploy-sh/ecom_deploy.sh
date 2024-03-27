#!/bin/bash 

#####################################################################################
# Author ::: Vivaan Shiromani 
# Date   ::: 27/03/2024
# About  ::: Multi-os localhost LAMP stack E-commerce application deployment script 
######################################################################################

# Todo --- See about the exit into functions with return if needed ; and test the script into VM's 

DEBIAN_PKG_LST="git firewalld apache2 mysql-server php php-mysql -y"
CENTOS_PKG_LST="git firewalld httpd mariadb-server php php-mysqlnd -y" 

DEBIAN_SERVICE_LST="firewalld apache2 mysql"
CENTOS_SERVICE_LST="firewalld httpd mariadb"

PORT_ARR=(80 3306)

DB_HOST="localhost"

checkServicePort() {

    if [ "$1" == "s" ]; then
        
        if ! sudo systemctl start "$2" && sudo systemctl enable "$2"; then 

            echo "ERROR: SERVICES NOT ABLE TO START OR ENABLE" 
            exit 1
        fi

    elif [ "$1" == "p" ]; then

        # declare local array ("$@") will capture all elements  
        local port_arr=("$@") 

        # take port one-by-one using ${arr_name[@]} synatx 
        for port in "${port_arr[@]}"; do

            if ! firewall-cmd --permanent --zone=public --add-port="$port"/tcp; then 

                echo "ERROR: PORT $port HAVING ISSUES IN ADDING IN FIREWALL"
                exit 1
            fi

        done

        firewall-cmd --reload
    fi

}

checkPackage() {

    if ! sudo "$1" update &> /dev/null &&  sudo "$1" upgrade &> /dev/null; then 

        echo "ERROR: UPDATING SYSTEM"
        exit 1
    fi

    # Installing required packages 
    if ! sudo "$1" install "$2" &> /dev/null; then 

        echo "ERROR: INSTALLING PACKAGES"
        exit 1 
    fi

}

databaseConfig() {

    read -p -r "Enter Datbase Username: " DB_USER
    read -p -r "Enter Database Name: " DB_NAME 
    
    echo -n "Enter Database Password: " 
    read -s -r DB_PASSWD

    # SQL Commands to load into mysql 

cat > db_sql_commands.sql <<-EOF 
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASSWD';
GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'$DB_HOST';
FLUSH PRIVILEGES;
EOF

    # here pipe statements cannot have a single exit code so pipestatus array variable is used to 
    # seperate command exit codes one-by-one 

    if ! sudo cat db_sql_commands.sql | mysql; then

        if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
                echo "ERROR: Failed to read database script"
        
            elif [[ ${PIPESTATUS[1]} -ne 0 ]]; then

                echo "ERROR: Failed to execute MySQL command"
        fi

        exit 1
    else

        # Load Product Inventory Information to database
        sudo rm db_sql_commands.sql 

cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
EOF

        # PIPESTATUS array has all exit codes for each command in the pipe 
        if ! sudo cat db-load-script.sql | mysql; then
        
            if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
                echo "ERROR: Failed to read product db script"
        
            elif [[ ${PIPESTATUS[1]} -ne 0 ]]; then

                echo "ERROR: Failed to execute product MySQL db command"
        fi
            exit 1
        
        fi


    fi


}

webSetup() {

    # Pkg manager specific functions 

    if [ "$1" == "apt" ]; then

        echo "INFO: APT BASED LAMP STACK E-COMMERCE APP INSTALLATION"

        # Update and Upgrade system 
        checkPackage "$1" "$DEBIAN_PKG_LST"
        
        # Check Start and Enable Services  
        checkServicePort "s" "$DEBIAN_SERVICE_LST" 
    
    elif [ "$1" == "yum" ]; then
        
        echo "INFO: YUM BASED LAMP STACK E-COMMERCE APP INSTALLATION"

        # Update and Upgrade system 
        checkPackage "$1" "$CENTOS_PKG_LST"
        
        # Check Start and Enable Services  
        checkServicePort "s" "$CENTOS_SERVICE_LST"

        # Change DirectoryIndex index.html to DirectoryIndex index.php to make the php page the default page
        sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

    fi 

    # COMMON FUNCTIONS .... 
    
    # Allow ports to firewall using firewall-cmd
    # apache2 - 80 ; mysql - 3306  
    # passing array into function 
    checkServicePort "p" "${PORT_ARR[@]}"
    # Port have been successfully added to firewalld 

    # Now create new ecommerce user, database, password, on localhost ask necessary details 
    databaseConfig

    # delete any folders and file in /var/www/html 
    sudo rm -rf /var/www/html/*

    # download the code to /var/www/html 
    echo "###################### CLONE CODE"
    
    echo 
    
    sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

    # Now replace all the database connection details in index.php file 

    sudo sed -i 's///$link = mysqli_connect('172.20.1.101', 'ecomuser', 'ecompassword', 'ecomdb');/$link = mysqli_connect('$DB_HOST', '"$DB_USER"', '"$DB_PASSWD"', '"$DB_NAME"')/g' /var/www/html/index.php

    sudo sed -i 's/$dbHost = getenv('DB_HOST');/ //$dbHost = getenv('DB_HOST');/g' /var/www/html/index.php

    sudo sed -i 's/$dbUser = getenv('DB_USER');/ //$dbUser = getenv('DB_USER');/g' /var/www/html/index.php

    sudo sed -i 's/$dbPassword = getenv('DB_PASSWORD');/ //$dbPassword = getenv('DB_PASSWORD');/g' /var/www/html/index.php

    sudo sed -i 's/$dbName = getenv('DB_NAME');/ //$dbName = getenv('DB_NAME');/g' /var/www/html/index.php
    
    sudo sed -i 's/$link = mysqli_connect($dbHost, $dbUser, $dbPassword, $dbName);/ //$link = mysqli_connect($dbHost, $dbUser, $dbPassword, $dbName);/g' /var/www/html/index.php

}


if apt --help &> /dev/null; then 
    
    webSetup "apt"

else
    webSetup "yum"

fi