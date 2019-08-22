#!/bin/bash

PRIVATEREGISTRY=private.registy.com

usage() {

	echo -n "functions [OPTION]

Script to reload, start and stop the docker stack.

 Options:
  -h      Show this help menu
  remove  Removes all stack components (stack, network and volume)
  reload  Reload the stack
  start   Start the stack
  stop    Stop the stack
"

}

function checkFile () {

	if [[ -f docker-stack.yml ]]; then
		return 0
	else
		printf "\033[0;31m\e[1mPlease, run this script in the same directory as the file 'docker-stack.yml'.\e[0m\n"
		exit 1
	fi
}

function checkSwarm () {

	if [[ "$(docker info --format '{{.Swarm.LocalNodeState}}')" == "inactive" ]]; then
		printf "\e[34m\e[1mHost is not in swarm mode.\e[0m\n"
		printf "\e[34m\e[1mPutting the host in swarm mode.\e[0m\n"
		docker swarm init --advertise-addr $(ip a | grep 192.168.56 | awk '{print $(NF)}')
	else
		return 0
	fi
}

function login () {

	if [[ "$(cat ~/.docker/config.json | grep ${PRIVATEREGISTRY})" ]]; then
		return 0
	else
		printf "\e[34m\e[1mYou need to login on the registry ${PRIVATEREGISTRY}.\e[0m\n"
		printf "\e[34m\e[1mdocker login ${PRIVATEREGISTRY}\e[0m\n"
		printf "\e[34m\e[1mPlease, type the your username and password. They are the same as your email.\e[0m\n"
		docker login ${PRIVATEREGISTRY}
	fi
	
}

function removeAll () {

	printf "\e[33m\e[1mThis will remove all stack components (stack, network, volume).\e[0m\n"
	printf "\e[33m\e[1mAre you sure you want to proceed? (y/N)\e[0m\n"
	read -r ANSWER

	if [[ ${ANSWER} == "y" || ${ANSWER} == "Y" ]]; then
		printf "\e[34m\e[1mStopping the stack\e[0m\n"
        	docker stack rm dev
		printf "\e[34m\e[1mRemoving the network\e[0m\n"
       		docker network rm ingress
		printf "\e[34m\e[1mRemoving the volume\e[0m\n"
        	docker volume rm db-dev
	else
		printf "\e[34m\e[1mProcedure cancelled.\e[0m\n"
	fi

}

function network () {

	if [[ "$(docker network inspect ingress)" ]]; then
		printf "Network already exists\n"
	else
		printf "\e[34m\e[1mCreating the network 'ingress'.\n"
 	        docker network create --ingress --driver overlay ingress
	fi

}

function volume () {

	if docker volume ls | grep -q 'db-dev'; then
		printf "Volume already exists\n"
	else
		printf "\e[34m\e[1mCreating the volume db-dev!\e[0m\n"
         	docker volume create db-dev
	fi

}

function reloadStack () {

	printf "\e[34m\e[1mReloading the stack!\e[0m\n"
	docker stack deploy --with-registry-auth -c docker-stack.yml dev

}

function startStack () {

	if grep -q ${PRIVATEREGISTRY} ~/.docker/config.json; then
		printf "\e[34m\e[1mStarting the stack dev!\e[0m\n"
		docker stack deploy -c docker-stack.yml dev
	else
		login
	fi
		
}

function stopStack () {

	printf "\e[34m\e[1mStopping the stack dev.\e[0m\n"
	docker stack rm dev

}

case "$1" in

	-\?)    
	        echo ""	
		usage >&2
	        exit 2
		;;
		
	start)
		login
		checkSwarm
		checkFile
		network
		volume
		startStack
		exit 0
		;;

	stop)
		checkFile
		stopStack
		exit 0
	        ;;

	reload)
		checkSswarm
		checkFile
		reloadStack
		exit 0
		;;
		
	remove)
		checkFile
		removeAll
		exit 0
		;;

	-h) 
		usage >&2;
		exit 0
		;;
	
        *)
	        echo ""	
		echo "Invalid option: '$1'."
		usage >&2
	        exit 2
		;;
		
esac
