#!/bin/bash

#############################################################################
#Script Name    :notification.sh                                            #
#Description    :Checks if apache is on. If not sends a message to telegram #
#Args           :None                                                       #
#Author  	      :Leandro Solagna                                            #
#Date   	      :01/01/2019                                                 #
#############################################################################

CHATID="<yourID"
KEY="<yourToken>"
TIME="10"
URL="https://api.telegram.org/bot$KEY/sendMessage"
TEXT="The apache is DOWN. Better check it, buddy."
LOGFILE=/var/log/telegram-notification.log

if [ "`systemctl is-active httpd`" == "inactive" ]; then
  curl -s --max-time $TIME -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT" $URL >/dev/null
else
  date >> $LOGFILE
  echo "Not sending notifications" >> $LOGFILE
fi
