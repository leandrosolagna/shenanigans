#!/bin/bash

#############################################
# Script to deploy and application          #
# This was before I learned about webhooks. #
#############################################


PATH_APP=/var/www/html/diretorio
GIT_USER=git.app
GIT_USER_PASSWD=senha
GIT_PROJ=git.org.br/app/app.git
GIT_BRANCH=develop

        if [ -d "$PATH_APP" ]; then
		cd $PATH_APP
                date >> /var/log/autodeploy.log
                git fetch origin
                git reset --hard origin/develop
                git pull https://$GIT_USER:$GIT_USER_PASSWD@$GIT_PROJ $GIT_BRANCH >> /var/log/autodeploy.log
                chown -R apache:apache $PATH_APP
                systemctl reload httpd
                exit 0;
        fi

mkdir $PATH_APP
git clone https://$GIT_USER:$GIT_USER_PASSWD@$GIT_PROJ -b $GIT_BRANCH $PATH_APP
chown -R apache:apache $PATH_APP
systemctl reload httpd
