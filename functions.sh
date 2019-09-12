#!/bin/bash

PRIVATEREGISTRY=your.private.registry.com

###COLORS VARIABLES###

BLUE=$'\e[34m\e[1m'
GREEN=$'\e[32m\e[1m'
RED=$'\033[0;31m\e[1m'
WHITE=$'\e[0m'
YELLOW=$'\e[33m\e[1m'

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
		printf "${RED}Please, run this script in the same directory as the file 'docker-stack.yml'.${WHITE}\n"
		exit 1
	fi
}

function checkSwarm () {

	if [[ "$(docker info --format '{{.Swarm.LocalNodeState}}')" == "inactive" ]]; then
		printf "${BLUE}Host is not in swarm mode.${WHITE}\n"
		printf "${BLUE}Putting the host in swarm mode.${WHITE}\n"
		docker swarm init --advertise-addr $(ip a | grep 192.168.56 | awk '{print $(NF)}')
	else
		return 0
	fi
}

function login () {

	if [[ "$(cat ~/.docker/config.json | grep ${PRIVATEREGISTRY})" ]]; then
		return 0
	else
		printf "${BLUE}You need to login on the registry ${PRIVATEREGISTRY}.${WHITE}\n"
		printf "${BLUE}docker login ${PRIVATEREGISTRY}${WHITE}\n"
		printf "${BLUE}Please, type the your username and password. They are the same as your email.${WHITE}\n"
		docker login ${PRIVATEREGISTRY}
	fi
	
}

function removeAll () {

	printf "${YELLOW}This will remove all stack components (stack, network, volume).${WHITE}\n"
	printf "${YELLOW}Are you sure you want to proceed? (y/N)${WHITE}\n"
	read -r ANSWER

	if [[ ${ANSWER} == "y" || ${ANSWER} == "Y" ]]; then
		printf "${BLUE}Stopping the stack${WHITE}\n"
        	docker stack rm dev
		printf "${BLUE}Removing the network${WHITE}\n"
       		docker network rm ingress
		printf "${BLUE}Removing the volume${WHITE}\n"
        	docker volume rm db-dev
	else
		printf "${BLUE}Procedure cancelled.${WHITE}\n"
	fi

}

function network () {

	if docker network ls | grep -q 'ingress'; then
		return 0
	else
		printf "${BLUE}Creating the network 'ingress'${WHITE}\n"
 	        docker network create --ingress --driver overlay ingress
	fi

}

function volume () {

	if docker volume ls | grep -q 'db-dev'; then
		return 0
	else
		printf "${BLUE}Creating the volume db-dev${WHITE}\n"
         	docker volume create db-dev
	fi

}

function reloadStack () {

	printf "${BLUE}Reloading the stack${WHITE}\n"
	docker stack deploy --with-registry-auth -c docker-stack.yml dev

}

function startStack () {

	if grep -q ${PRIVATEREGISTRY} ~/.docker/config.json; then
		printf "${GREEN}Starting the stack dev${WHITE}\n"
		docker stack deploy --with-registry-auth -c docker-stack.yml dev
	else
		login
	fi
		
}

function stopStack () {

	printf "${GREEN}Stopping the stack dev${WHITE}\n"
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
