##############################################################         
#This is a simple script created to commit your files.       #
#It needs to be inside your git folder for this to happen.   #
#The script will get the message you write, add your files,  #
#commit them with the message you wrote, then it will push   #
# in your branch, switch to master, pull the changes from one# 
#branch to master and push them to master and finally        # 
# it will go back your branch                                #
#                                                            #
#Author: Leandro Solagna                                     #
#Date: July 3rd 2016                                         #
#                                                            #
#Anyone can use this, just change the branches name!         #
##############################################################

echo "Enter your message for commit: "
read MESSAGE

echo "You typed: $MESSAGE"

git add *
git commit -m "$MESSAGE"
git push origin teste
git checkout master
git pull origin teste
git push origin master
git checkout teste
git branch -v
