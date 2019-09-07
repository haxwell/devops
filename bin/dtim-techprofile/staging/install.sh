#!/bin/bash

apt install -y ssmtp xvfb libgtk-3-0 colord libgconf2-4 libxss1

cd /home/quizki/src/
git clone git@github.com:haxwell/dtim-techprofile.git


cd /home/quizki/src/
git clone git@github.com:haxwell/dtim-techprofile-mobile.git

#cd /home/quizki/src/
#git clone git@github.com:haxwell/dtim-techprofile-browser.git

echo "[client]" > /home/quizki/.my.cnf
echo "user=springuser_dtim" >> /home/quizki/.my.cnf
echo "password=ThePassword" >> /home/quizki/.my.cnf

echo -e "\n\n\n# BEGIN"

echo -e "\n\n\n#### MYSQL INIT COMMANDS #####"
echo "echo \"CREATE USER 'springuser_dtim'@'localhost' IDENTIFIED BY 'ThePassword';\" >> buildTheDB.sql"
echo "echo \"GRANT ALL ON dtim_db.* TO 'springuser_dtim'@'localhost';\" >> buildTheDB.sql";
echo "echo \"CREATE DATABASE dtim_db;\" >> buildTheDB.sql";
echo -e '\nsudo mysql -u root < buildTheDB.sql'
echo "#######"

# SSMTP Mail Settings
echo "sudo sed -i 's/root=postmaster/root=easyahinfo@gmail.com/' /etc/ssmtp/ssmtp.conf"
echo "sudo sed -i 's/mailhub=mail/mailhub=smtp.gmail.com:587/' /etc/ssmtp/ssmtp.conf"
echo "sudo sed -i 's/#rewriteDomain=/rewriteDomain=gmail.com/' /etc/ssmtp/ssmtp.conf"
echo "sudo sed -i 's/#FromLineOverride=YES/FromLineOverride=YES/' /etc/ssmtp/ssmtp.conf"
echo "sudo sed -i '/^mailhub=smtp.gmail.com:587/a AuthUser=easyahinfo@gmail.com\nAuthPass=password11!\nUseTLS=YES\nUseSTARTTLS=YES' /etc/ssmtp/ssmtp.conf"

#write out current crontab
echo -e '\n\ntouch mycron'
echo -e 'crontab mycron'
#echo new cron into cron file
echo 'echo "HAX_APP_NAME=dtim-techprofile" >> mycron'
echo 'echo "HAX_APP_DB_NAME=dtim_db" >> mycron'
echo 'echo "HAX_APP_ENVIRONMENT=STAGING" >> mycron'
echo 'echo -e "\n\n" >> mycron'
echo 'echo "@reboot bash /home/quizki/src/dtim-techprofile/bin/onstartup.sh" >> mycron'
echo 'echo "50 7 * * *  bash /home/quizki/src/dtim-techprofile/bin/backup/create-backup-tar.sh" >> mycron'
echo 'echo "19 15 * * * bash /home/quizki/src/dtim-techprofile-mobile/bin/automated_test.sh >> /home/quizki/todays-automated-tests.out" >> mycron'

#install new cron file
echo 'crontab mycron'
echo 'rm mycron'
echo "#"

# Application File Stuff
## permissions
echo "sudo chown quizki src/dtim-techprofile -R"
echo "sudo chgrp quizki src/dtim-techprofile -R"
echo "sudo chown quizki src/dtim-techprofile-mobile -R"
echo "sudo chgrp quizki src/dtim-techprofile-mobile -R"

echo "echo '{}' > /home/quizki/src/dtim-techprofile-mobile/cypress.json"

echo "cd /home/quizki/src/$HAX_APP_NAME"
echo "git checkout dev"
echo "git pull"

echo "scp $HAX_CONFIG_SERVER_USER_NAME@$HAX_CONFIG_SERVER_IP:/home/$HAX_CONFIG_SERVER_USER_NAME/haxwell_infrastructure/$HAX_APP_NAME/$HAX_APP_ENVIRONMENT/application.properties /home/quizki/src/dtim-techprofile/src/main/resources/application.properties"

echo -e "\n\n\n# END"
echo "--------------------------------"
echo -e '\nRun the above commands to finish setup!\n\n'
echo -e '\nDONE INSTALLING ... reboot, and the site is ready to go'

