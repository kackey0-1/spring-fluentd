#!/bin/bash

###################################################################
#Script Name	: configure_nginx.sh
#Description	: userdata template script to configure kibana
###################################################################

docker-compose -v
if [ "$?" -ne "0" ]
then
    yum update -y
    yum install -y git
    yum install -y docker
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
    chmod +x /usr/bin/docker-compose
    curl -O https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz
    tar zxvf openjdk-11.0.1_linux-x64_bin.tar.gz
    mv jdk-11.0.1 /usr/local/
    cd /root
    echo "export JAVA_HOME=/usr/local/jdk-11.0.1" >> /root/.bashrc
    echo "export PATH=$PATH:$JAVA_HOME/bin" >> /root/.bashrc
    git clone https://github.com@github.com/kackey0-1/spring-logstash.git
    echo "${file("../common/docker-compose.yml")}" > /root/spring-logstash/docker-compose.yml
    sed -i "s/_ES_DOMAIN/${ES_ENDPOINT}/g" /root/spring-logstash/docker-compose.yml
fi

cd /root/spring-logstash
service docker start
service docker enable
docker-compose up -d
