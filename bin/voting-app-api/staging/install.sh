!/bin/bash

apt install -y ssmtp xvfb libgtk-3-0 colord libgconf2-4 libxss1

cd /home/quizki/src/
git clone git@github.com:haxwell/voting-app-api.git


cd /home/quizki/src/
git clone git@github.com:haxwell/voting-app-mobile.git

#cd /home/quizki/src/
#git clone git@github.com:haxwell/voting-app-browser.git

echo "[client]" > /home/quizki/.my.cnf
echo "user=springuser_voting" >> /home/quizki/.my.cnf
echo "password=supersecure" >> /home/quizki/.my.cnf

echo -e "\n\n\n# BEGIN"

echo -e "\n\n\n#### MYSQL INIT COMMANDS #####"
echo "echo \"CREATE USER 'springuser_voting'@'localhost' IDENTIFIED BY 'supersecure';\" >> buildTheDB.sql"
echo "echo \"GRANT ALL ON voting_db.* TO 'springuser_voting'@'localhost';\" >> buildTheDB.sql";
echo "echo \"CREATE DATABASE voting_db;\" >> buildTheDB.sql";
echo -e '\nsudo mysql -u root < buildTheDB.sql'
echo -e '\nrm buildTheDB.sql'
echo "#######"

# SSMTP Mail Settings
echo "sudo sed -i 's/root=postmaster/root=kingsvotingapp@gmail.com/' /etc/ssmtp/ssmtp.conf"
echo "sudo sed -i 's/mailhub=mail/mailhub=smtp.gmail.com:587/' /etc/ssmtp/ssmtp.conf"
echo "sudo sed -i 's/#rewriteDomain=/rewriteDomain=gmail.com/' /etc/ssmtp/ssmtp.conf"
echo "sudo sed -i 's/#FromLineOverride=YES/FromLineOverride=YES/' /etc/ssmtp/ssmtp.conf"
echo "sudo sed -i '/^mailhub=smtp.gmail.com:587/a AuthUser=kingsvotingapp@gmail.com\nAuthPass=password11!\nUseTLS=YES\nUseSTARTTLS=YES' /etc/ssmtp/ssmtp.conf"

#write out current crontab
echo -e '\n\ntouch mycron'
echo -e 'crontab mycron'
#echo new cron into cron file
echo 'echo "HAX_APP_NAME=$HAX_APP_NAME" >> mycron'
echo 'echo "HAX_APP_DB_NAME=$HAX_APP_DB_NAME" >> mycron'
echo 'echo "HAX_APP_ENVIRONMENT=$HAX_APP_ENVIRONMENT" >> mycron'
echo 'echo -e "\n\n" >> mycron'
echo 'echo "@reboot bash /home/quizki/src/voting-app-api/bin/onstartup.sh" >> mycron'
echo 'echo "50 7 * * *  bash /home/quizki/src/voting-app-api/bin/backup/create-backup-tar.sh" >> mycron'
echo 'echo "19 15 * * * bash /home/quizki/src/voting-app-mobile/bin/automated_test.sh >> /home/quizki/todays-automated-tests.out" >> mycron'

#install new cron file
echo 'crontab mycron'
echo 'rm mycron'
echo "#"

# Application File Stuff
## permissions
echo "sudo chown quizki src/voting-app-api -R"
echo "sudo chgrp quizki src/voting-app-api -R"
echo "sudo chown quizki src/voting-app-mobile -R"
echo "sudo chgrp quizki src/voting-app-mobile -R"

echo "echo '{}' > /home/quizki/src/voting-app-mobile/cypress.json"

# echo "scp $HAX_CONFIG_SERVER_USER_NAME@$HAX_CONFIG_SERVER_IP:/home/$HAX_CONFIG_SERVER_USER_NAME/haxwell-devops/bin/$HAX_APP_NAME/$HAX_APP_ENVIRONMENT/dotprofile /home/quizki/.profile"

echo "cd /home/quizki/src/$HAX_APP_NAME"
echo "scp $HAX_CONFIG_SERVER_USER_NAME@$HAX_CONFIG_SERVER_IP:/home/$HAX_CONFIG_SERVER_USER_NAME/haxwell-devops/bin/$HAX_APP_NAME/$HAX_APP_ENVIRONMENT/application.properties /home/quizki/src/voting-app-api/src/main/resources/application.properties"
echo "git pull"   # we do this here, so it doesn't happen the first time the server is brought up (it does a git pull on every restart)


echo -e "\n\n\n# END"
echo "--------------------------------"
echo -e '\nRun the above commands to finish setup!\n\n'
echo -e '\nDONE INSTALLING ... reboot, and the site is ready to go'

