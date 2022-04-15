#!/bin/bash

# HAXWELL DEVOPS - Build a brand new droplet to a production ready Hax App instance

# You put the id_rsa and id_rsa.pub files in ~/.ssh
# You pass in the app name, db name, environment (staging|prod), and the config server's ip
#  and user name.

# This script will do the common setup any HAX APP would need. Then it will make a call to
#  the server, and get the setup script for this app.

PWD=$(pwd)

if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
        exit
    fi


#
# TODO: Check if this script has already run, so we don't accidentally run it again.
#
#

while getopts n:e:a:u: option
do
    case "${option}"
        in
        n) HAX_APP_NAME=${OPTARG,,};; # The ,, at the end makes the variable lowercase. w00t
        e) HAX_APP_ENVIRONMENT=${OPTARG,,};;
        a) HAX_CONFIG_SERVER_IP=${OPTARG,,};;
        u) HAX_CONFIG_SERVER_USER_NAME=${OPTARG,,};;
    esac
done

if [ -z $HAX_APP_NAME ] || [ -z $HAX_APP_ENVIRONMENT ]; then
    echo "You need values for HAX_APP_NAME, HAX_APP_ENVIRONMENT"
    echo
    echo "Usage 1:"
    echo "./new-server-install -n eog_api -e staging|prod -a [config-server-ip] -u [config-server-user-name]"
    echo
    exit 1
fi

if [ -z $HAX_CONFIG_SERVER_USER_NAME ] || [ -z $HAX_CONFIG_SERVER_IP ]; then
    echo "There should be a server where this script can get a default .profile,"
    echo " and other app specific config files. That is the 'config server'."
    echo
    echo "Usage 2:"
    echo "./new-server-install -n eog_api -e staging|prod -a [config-server-ip] -u [config-server-user-name]"
    echo
    exit 1
fi

echo "Verifying ssh keys are in place..."
if [ ! -f "./.ssh/id_rsa" ] || [ ! -f "./.ssh/id_rsa.pub" ]; then 
    echo
    echo "You need to have ssh keys in place so this script can retrieve stuff from the config server ($HAX_CONFIG_SERVER_USER_NAME @ $HAX_CONFIG_SERVER_IP)"
    echo
    exit 1
fi

cp ./.ssh/* /root/.ssh

echo
echo SETTING .PROFILE FOR THIS APP
echo
scp3() {
scp $HAX_CONFIG_SERVER_USER_NAME@$HAX_CONFIG_SERVER_IP:/home/$HAX_CONFIG_SERVER_USER_NAME/haxwell-devops/bin/$HAX_APP_NAME/$HAX_APP_ENVIRONMENT/dotProfile ~/.profile
}

scp3

mkdir /home/quizki/apps
mkdir /home/quizki/src

chown quizki /home/quizki/apps -R
chgrp quizki /home/quizki/apps -R
chown quizki /home/quizki/src -R
chgrp quizki /home/quizki/src -R

####
# NODE 
####
echo 
echo INSTALLING NODE
echo
scp1() {
cd /home/quizki/apps/
mkdir node 
chown quizki /home/quizki/apps/node -R
chgrp quizki /home/quizki/apps/node -R

cd node
scp $HAX_CONFIG_SERVER_USER_NAME@$HAX_CONFIG_SERVER_IP:/home/$HAX_CONFIG_SERVER_USER_NAME/haxwell-devops/apps/node-v16.14.2-linux-x64.tar.xz node-v16.14.2-linux-x64.tar.xz
tar -xvf ./node-v16.14.2-linux-x64.tar.xz
ln -s node-v16.14.2-linux-x64 current
}

scp1

####
# JAVA
####
echo 
echo INSTALLING JAVA 
echo
scp2() {
cd /home/quizki/apps/
mkdir java
chown quizki /home/quizki/apps/java -R
chgrp quizki /home/quizki/apps/java -R

    cd java
scp $HAX_CONFIG_SERVER_USER_NAME@$HAX_CONFIG_SERVER_IP:/home/$HAX_CONFIG_SERVER_USER_NAME/haxwell-devops/apps/jdk-17_linux-x64_bin.tar.gz ./jdk17.tar.gz
tar -xvf ./jdk17.tar.gz
ln -s jdk-17 current

chown quizki /home/quizki/apps/java/current -R
chgrp quizki /home/quizki/apps/java/current -R

scp $HAX_CONFIG_SERVER_USER_NAME@$HAX_CONFIG_SERVER_IP:/home/$HAX_CONFIG_SERVER_USER_NAME/haxwell-devops/apps/mysql-connector-java-8.0.17.jar /home/quizki/apps/java/current/lib/.

chown quizki /home/quizki/apps/java/current -R
chgrp quizki /home/quizki/apps/java/current -R
}

scp2

####
# MYSQL
####
echo 
echo INSTALLING MYSQL
echo
cd /home/quizki/apps/
apt install -y mysql-server

####
# MAVEN
####
echo 
echo INSTALLING MAVEN 
echo
cd /home/quizki/apps/
apt install -y maven

git config --global user.email "haxwell@gmail.com"
git config --global user.name "Johnathan James"


####
# SSMTP
####
echo 
echo INSTALLING SSMTP
echo
cd /home/quizki/apps
apt install -y ssmtp


appinstall() {
cd /home/quizki
scp $HAX_CONFIG_SERVER_USER_NAME@$HAX_CONFIG_SERVER_IP:/home/$HAX_CONFIG_SERVER_USER_NAME/haxwell-devops/bin/$HAX_APP_NAME/$HAX_APP_ENVIRONMENT/install.sh .
chmod +x install.sh
chown quizki /home/quizki -R
chgrp quizki /home/quizki -R
source install.sh
}

appinstall

echo 
echo DONE INSTALLING ... you should reboot now!
echo

