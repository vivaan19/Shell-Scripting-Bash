#######################
# We need to install a software, if that software exists then no need to reinstall it again 
#######################

#/bin/bash 

if [ -e $(pwd)/prometheus-2.48.0.linux-amd64.tar.gz ]; then
    echo installed 
    tar -zxvf prometheus-2.48.0.linux-amd64.tar.gz
else
    echo not installed 
    wget https://github.com/prometheus/prometheus/releases/download/v2.48.0/prometheus-2.48.0.linux-amd64.tar.gz

fi