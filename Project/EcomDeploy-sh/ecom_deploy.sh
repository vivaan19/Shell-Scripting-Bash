#!/bin/bash 

#####################################################################################
# Author ::: Vivaan Shiromani 
# Date   ::: 27/03/2024
# About  ::: Multi-os localhost LAMP stack E-commerce application deployment script 
######################################################################################

# Todo --- See about the exit into functions with return if needed ; and test the script into VM's 

DEBIAN_PKG_LST=(git firewalld apache2 mysql-server php php-mysql)
CENTOS_PKG_LST=(git firewalld httpd mariadb-server php php-mysqlnd) 

DEBIAN_SERVICE_LST=(firewalld apache2 mysql)
CENTOS_SERVICE_LST=(firewalld httpd mariadb)

PORT_ARR=(80 3306)

DB_HOST="localhost"

checkServicePort() {

    func_type=$1
    
    shift
    
    arr=("$@")

    if [ "$func_type" == "s" ]; then

        # local service_arr=("$@")

        # local -n service_arr="$2"  will not work for bash version upto 4 


        for ser in "${arr[@]}"; do
        
            if ! sudo systemctl start "$ser" && sudo systemctl enable "$ser"; then 

                echo "ERROR: SERVICE - $ser NOT ABLE TO START OR ENABLE" 
                exit 1
            fi
        done

    elif [ "$func_type" == "p" ]; then
        
        # This will take whole argument as an array : (p 80 3306) like this 
        # declare local array ("$@") will capture all elements  
        # local port_arr=("$@") 

        # take reference of array ; if modified here it will get modified outside of the function also 
        # local -n port_arr="$2" 

        # take port one-by-one using ${arr_name[@]} synatx 
        for port in "${arr[@]}"; do

            if ! firewall-cmd --permanent --zone=public --add-port="$port"/tcp; then 

                echo "ERROR: PORT $port HAVING ISSUES IN ADDING IN FIREWALL"
                exit 1
            fi

        done

        firewall-cmd --reload
    fi

}

checkPackage() { 

    pkg_name=$1

    echo "INFO ####################### UPDATING SYSTEM"
    if ! sudo "$pkg_name" update -y &> /dev/null && sudo "$pkg_name" upgrade -y &> /dev/null; then 

        echo "ERROR: UPDATING SYSTEM"
        exit 1
    fi

    # Installing required packages 
    # local pkg_arr=("$@")
    
    echo "INFO ####################### INSTALLING PACKAGES"
    # take reference of array 

    # Todo --- local -n error in centos 

    shift

    # local -n pkg_arr=$2 local -n is not used in bash version upto 4         
    
    pkg_arr=("$@")        

    for pkg in "${pkg_arr[@]}"; do

        if ! sudo "$pkg_name" install "$pkg" -y; then 

            echo "ERROR: INSTALLING PACKAGE - $pkg"
            exit 1 
        fi
    done

}

dbCommand() {

    if [ "$1" == "db_sql_commands" ]; then 
 
cat > "$1".sql <<-EOF 
    CREATE DATABASE $2;
    CREATE USER '$3'@'$DB_HOST' IDENTIFIED BY '$4';
    GRANT ALL PRIVILEGES ON *.* TO '$3'@'$DB_HOST';
    FLUSH PRIVILEGES;
EOF

elif [ "$1" == "db_load_script" ]; then

cat > "$1".sql <<-EOF
    USE $2;
    CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;
    INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");
EOF

fi

    sudo cat "$1".sql | mysql
    es=$? 
    
    if [ $es -ne 0 ]; then 
        echo "ERROR: IN $1 sql file"
        exit 1
    else 
        echo "INFO #################### SQL COMMANDS DONE"
        # sudo rm "$1".sql
    
    fi 
}

databaseConfig() {

    while true; do
        
        read -rp "Enter Datbase Username: " DB_USER
        
        if_exists=$(sudo mysql -sN -e "SELECT COUNT(*) FROM mysql.user WHERE User = '${DB_USER}'")
        
        # Check if database user already exists - if count of the user is 1 then the user exists 
        if [[ $if_exists -lt 1 ]]; then

            echo "INFO ############## DATBASE USER DOES NOT EXIST" 

            read -rp "Enter Database Name: " DB_NAME 
            read -rsp "Enter Database Password: " DB_PASSWD
        
            dbCommand "db_sql_commands" "$DB_NAME" "$DB_USER" "$DB_PASSWD" 
            dbCommand "db_load_script" "$DB_NAME" "$DB_USER" "$DB_PASSWD" 
            
            break

        else 
            echo "ERROR DATBASE USER EXISTS : CREATE A NEW USER FIRST" 
        fi

    done
     
    # here pipe statements cannot have a single exit code so pipestatus array variable is used to 
    # seperate command exit codes one-by-one 

    # Load Product Inventory Information to database

        # PIPESTATUS array has all exit codes for each command in the pipe 
    #     if ! sudo cat db-load-script.sql | mysql; then
        
    #         if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    #             echo "ERROR: Failed to read product db script"
        
    #         elif [[ ${PIPESTATUS[1]} -ne 0 ]]; then

    #             echo "ERROR: Failed to execute product MySQL db command"
    #         fi
    #         exit 1
        
    #     fi

}

serviceRestart() {

    if [ $1 == "apt" ]; then

        if ! sudo systemctl restart apache2; then

            echo "ERROR: ALL PROCESS DONE BUT NOT ABLE TO RESTART APACHE2 SERVICE"
            exit1 
        fi

    elif [ $1 == "yum" ]; then
        if ! sudo systemctl restart httpd; then

            echo "ERROR: ALL PROCESS DONE BUT NOT ABLE TO RESTART HTTPD SERVICE"
            exit1 
        fi
    fi

}

webSetup() {

    # Pkg manager specific functions 

    if [ "$1" == "apt" ]; then

        echo "INFO: APT BASED LAMP STACK E-COMMERCE APP INSTALLATION"

        # Update and Upgrade system 
        checkPackage "apt" ${DEBIAN_PKG_LST[@]}
        
        # Check Start and Enable Services  
        checkServicePort "s" ${DEBIAN_SERVICE_LST[@]}
    
    elif [ "$1" == "yum" ]; then
        
        echo "INFO: YUM BASED LAMP STACK E-COMMERCE APP INSTALLATION"

        # Update and Upgrade system 
        checkPackage "yum" ${CENTOS_PKG_LST[@]}
        
        # Check Start and Enable Services  
        checkServicePort "s" ${CENTOS_SERVICE_LST[@]}

        # Change DirectoryIndex index.html to DirectoryIndex index.php to make the php page the default page
        sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

    fi 

    # COMMON FUNCTIONS .... 
    
    # Allow ports to firewall using firewall-cmd
    # apache2 - 80 ; mysql - 3306  
    # passing array into function 
    checkServicePort "p" ${PORT_ARR[@]}
    # Port have been successfully added to firewalld 

    # Now create new ecommerce user, database, password, on localhost ask necessary details 
    databaseConfig

    # delete any folders and file in /var/www/html 
    sudo rm -rf /var/www/html/*

    echo 
    # download the code to /var/www/html 
    echo "###################### CLONE CODE"
    
    echo 
    
    sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git

    sudo cp -r learning-app-ecommerce/* /var/www/html
    
    sudo rm -rf learning-app-ecommerce

    PHP_FNAME="/var/www/html/index.php"

    if [ -f "$PHP_FNAME" ]; then

        # first comment the strings 
                
        sudo sed -i "s#\$link = mysqli_connect(\$dbHost, \$dbUser, \$dbPassword, \$dbName);#//#g" $PHP_FNAME 
        sudo sed -i "s#\$dbHost#//\$dbHost#g"  $PHP_FNAME
        sudo sed -i "s#\$dbUser#//\$dbUser#g"  $PHP_FNAME
        sudo sed -i "s#\$dbPassword#//\$dbPassword#g"  $PHP_FNAME
        sudo sed -i "s#\$dbName#//\$dbName#g"  $PHP_FNAME
        sudo sed -i "s#// \$link = mysqli_connect('172.20.1.101', 'ecomuser', 'ecompassword', 'ecomdb')#\$link('$DB_HOST', '$DB_USER', '$DB_PASSWD', '$DB_NAME')#g" $PHP_FNAME
        

        
    fi
}


if apt --help &> /dev/null; then 
    
    webSetup "apt"
    serviceRestart "apt" 

else
    webSetup "yum"
    serviceRestart "yum" 

fi