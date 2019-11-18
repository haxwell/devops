#!/bin/bash

apt install -y ssmtp xvfb libgtk-3-0 colord libgconf2-4 libxss1

cd /home/quizki/src/
git clone git@github.com:haxwell/eog-api.git


cd /home/quizki/src/
git clone git@github.com:haxwell/eog-mobile2.git
mv eog-mobile2 eog-mobile

cd /home/quizki/apps
mkdir liquibase
cd liquibase
scp $HAX_CONFIG_SERVER_USER_NAME@$HAX_CONFIG_SERVER_IP:/home/$HAX_CONFIG_SERVER_USER_NAME/haxwell-devops/apps/liquibase-3.8.0-bin.tar.gz liquibase.tar.gz
tar -xvf ./liquibase.tar.gz

echo "[client]" > /home/quizki/.my.cnf
echo "user=springuser_eog" >> /home/quizki/.my.cnf
echo "password=ThePassword" >> /home/quizki/.my.cnf


echo -e "\n\n\n# BEGIN"

# Liquibase 
echo "sudo chown quizki /home/quizki/my.cnf"
echo "sudo chgrp quizki /home/quizki/my.cnf"
echo "sudo chown quizki /home/quizki/apps/liquibase -R"
echo "sudo chgrp quizki /home/quizki/apps/liquibase -R"
## MySQL Connector in Liquibase
echo "scp $HAX_CONFIG_SERVER_USER_NAME@$HAX_CONFIG_SERVER_IP:/home/$HAX_CONFIG_SERVER_USER_NAME/haxwell-devops/apps/mysql-connector-java-8.0.17.jar /home/quizki/apps/liquibase/lib/."

echo -e "#### MYSQL INIT COMMANDS #####"
echo "echo \"CREATE USER 'springuser_eog'@'localhost' IDENTIFIED BY 'ThePassword';\" > buildTheDB.sql"
echo "echo \"GRANT ALL ON eog_db.* TO 'springuser_eog'@'localhost';\" >> buildTheDB.sql";
echo "echo \"CREATE DATABASE eog_db;\" >> buildTheDB.sql";
echo -e '\nsudo mysql -u root < buildTheDB.sql'

echo "cd /home/quizki/apps/liquibase && mysql -e \"DROP DATABASE eog_db; CREATE DATABASE eog_db\" && mysql -e \"\`cat /home/quizki/src/eog-api/src/main/resources/META-INF/sql/init_eog_db.sql\`\" && ./liquibase --changeLogFile=/home/quizki/src/eog-api/src/main/resources/META-INF/sql/migration/changelog-master.xml --username=springuser_eog --password=ThePassword --url=\"jdbc:mysql://localhost:3306/eog_db?verifyServerCertificate=false&useSSL=false\" --driver=com.mysql.jdbc.Driver --contexts=test update"
echo "#######"

# SSMTP Mail Settings
echo "sudo sed -i 's/root=postmaster/root=easyahinfo@gmail.com/' /etc/ssmtp/ssmtp.conf"
echo "sudo sed -i 's/mailhub=mail/mailhub=smtp.gmail.com:587/' /etc/ssmtp/ssmtp.conf"
echo "sudo sed -i 's/#rewriteDomain=/rewriteDomain=gmail.com/' /etc/ssmtp/ssmtp.conf"
echo "sudo sed -i 's/#FromLineOverride=YES/FromLineOverride=YES/' /etc/ssmtp/ssmtp.conf"
echo "sudo sed -i '/^mailhub=smtp.gmail.com:587/a AuthUser=easyahinfo@gmail.com\nAuthPass=password11!\nUseTLS=YES\nUseSTARTTLS=YES' /etc/ssmtp/ssmtp.conf"

#write out current crontab
echo -e '\n\ncd';
echo -e 'touch mycron'
echo -e 'crontab mycron'
#echo new cron into cron file
echo 'echo "HAX_APP_NAME=eog-api" >> mycron'
echo 'echo "HAX_APP_DB_NAME=eog_db" >> mycron'
echo 'echo "HAX_APP_ENVIRONMENT=STAGING" >> mycron'
echo 'echo -e "\n\n" >> mycron'
echo 'echo "@reboot bash /home/quizki/src/eog-api/bin/onstartup.sh" >> mycron'
echo 'echo "@reboot bash /home/quizki/src/eog-mobile/bin/onstartup.sh" >> mycron'
echo 'echo "0 8 * * *  bash /home/quizki/src/eog-api/bin/backup/create-backup-tar.sh" >> mycron'
echo 'echo "29 15 * * * bash /home/quizki/src/eog-mobile/bin/automated_test.sh >> /home/quizki/todays-automated-tests.out" >> mycron'

#install new cron file
echo 'crontab mycron'
echo 'rm mycron'
echo "#"

# Application File Stuff
## permissions
echo "sudo chown quizki src/eog-api -R"
echo "sudo chown quizki src/eog-mobile -R"
echo "sudo chgrp quizki src/eog-api -R"
echo "sudo chgrp quizki src/eog-mobile -R"

echo "echo '{}' > /home/quizki/src/eog-mobile/cypress.json"

echo "cd /home/quizki/src/$HAX_APP_NAME"
echo "git checkout dev"
echo "scp $HAX_CONFIG_SERVER_USER_NAME@$HAX_CONFIG_SERVER_IP:/home/$HAX_CONFIG_SERVER_USER_NAME/haxwell-devops/bin/$HAX_APP_NAME/$HAX_APP_ENVIRONMENT/application.properties /home/quizki/src/eog-api/src/main/resources/application.properties"
echo "git pull"

# EOG-API Environment Files
echo "cd /home/quizki/src/$HAX_APP_FRONTEND_NAME"
echo "cp src/_environments/environment.${HAX_APP_ENVIRONMENT,,}.js src/_environments/environment.js"
echo "npm install ionic -g"
echo "npm install"

echo -e "\n\n\n# END"
echo "--------------------------------"

echo -e '\nRun the above commands to finish setup!\n\n'
echo -e '\nDONE INSTALLING ... reboot, and the site is ready to go'
