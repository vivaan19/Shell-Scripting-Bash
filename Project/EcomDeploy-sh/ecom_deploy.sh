#!/bin/bash 

###############################################################################################
# Author ::: Vivaan Shiromani 
# Date   ::: 27/03/2024
# About  ::: Multi-os (apt and yum) localhost LAMP stack 3-tier E-commerce application deployment script 
#################################################################################################

DEBIAN_PKG_LST=(git firewalld apache2 mysql-server php php-mysql)
CENTOS_PKG_LST=(git firewalld httpd mariadb-server php php-mysqlnd) 

DEBIAN_SERVICE_LST=(firewalld apache2 mysql)
CENTOS_SERVICE_LST=(firewalld httpd mariadb)

PORT_ARR=(80 3306)

DB_HOST="localhost"

#########################################################################################
# This function is used to update and upgrade the system using yum or apt package manager 
# Also to install various packages which will be used to for further processing 
# Arguments :: 
# $1 -- This is the package string -- either yum or apt 
# $2 -- Package array which will install package one-by-one here also array value is passed through value 
##########################################################################################

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

#########################################################################################################
# This function is used to start the service one-by-one as per list provided for either OS 
# And adding port of apache web server which is 80 and mysql which is 3306 to firewalld using firewall-cmd 
# Arguments : 
# $1 -- "s" or "p" to differentiate the function is working for service or port 
# arr -- this the array which is passed by value as ${array_name[@]} to the function and to access using this ("$@")
#
# This function also uses shift to change to second argument which is array after first argument 
##########################################################################################################
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

#######################################################################
# This function is used to make load .sql files to mysql to 
# create database, user on localhost and give various
# privileges. Also this function creates product table in the database  
# where all details including images of products is loaded 
# Arguments:: 
# $1 -- sql file name to have different .sql file to run 
# $2 -- Database name 
# $3 -- User name 
# $4 -- Database password 
#########################################################################
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
        sudo rm "$1".sql
    
    fi 
}

#######################################################################################################
# This function configures the database by reading input for user name, database and password 
# This function calls dbCommand function before performing validations for database and user existance 
# It has a while loop which gives users chance to re-enter new user name and database name 

# Args :: None 
#######################################################################################################
databaseConfig() {

    while true; do
        
        read -rp "Enter Database Username: " DB_USER
        read -rp "Enter Database Name: " DB_NAME
        
        if_user_exists=$(sudo mysql -sN -e "SELECT COUNT(*) FROM mysql.user WHERE User = '${DB_USER}'")
        if_db_exists=$(sudo mysql -sN -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${DB_NAME}'")

        # Check if database user already exists - if count of the user is 1 then the user exists 
        if [[ $if_user_exists -eq 0 && $if_db_exists -eq 0 ]]; then

            echo "INFO ############## DATABASE AND USER DOES NOT EXIST" 

            read -rsp "Enter Database Password: " DB_PASSWD
        
            dbCommand "db_sql_commands" "$DB_NAME" "$DB_USER" "$DB_PASSWD" 
            dbCommand "db_load_script" "$DB_NAME" "$DB_USER" "$DB_PASSWD" 
            
            break

        else 
            echo "ERROR ############## DATABASE AND USER EXISTS" 

            # if_product_t_exists = $(sudo mysql -sN -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DB_NAME' AND table_name LIKE 'products';")
            
            # if [ $if_product_t_exists -eq 0 ]; then
                
            #     echo "CREATING PRODUCT TABLE ---- " 
            #     dbCommand "db_load_script"
            
            # else

            #     # Here I want to get search for the password for the user and place into DB_PASSWD Variable 
        
        fi

    done
    


    # Usage of Pipe-status command  
    #############
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
    ##############


}

###############################################################################
# This function do's the main web configuration 
# It has all the common functions of yum and apt based os 
# like this function adds the relevant port to firewalld, clone code, 
# copy the code and replaces string in index.php file inside /var/www/html 
# Args ::: 
# NONE 
##################################################################################
webConfig() {

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

######################################################################################
# This function restarts the apache2 or httpd service after all operations performed
# Args :::: 
# $1 -- Package name -- yum or apt  
######################################################################################
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

######################################################################
# Main web setup function which calls all other function in the script 
######################################################################
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

    webConfig 

}


# Multi-os setup for apt based and yum based os 
if apt --help &> /dev/null; then 
    
    webSetup "apt"
    serviceRestart "apt" 

    # Check the status code 
    code=$(curl -Is localhost | grep HTTP | cut -d " " -f2)
    if [ $code -eq 200 ]; then
        echo "Status Code of application is 200 website successfully hosted"
    else 
        echo "Status Code of application is $code website hosting as some-problems"
    fi

else
    webSetup "yum"
    serviceRestart "yum" 

fi