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
		printf "\033[0;31mPlease, run this script in the same directory as the file 'docker-stack.yml'.\e[0m\n"
		exit 1
	fi
}

function checkSwarm () {

	if [[ "$(docker info --format '{{.Swarm.LocalNodeState}}')" == "inactive" ]]; then
		printf "Host is not in swarm mode.\n"
		printf "Putting the host in swarm mode.\n"
		docker swarm init --advertise-addr $(ip a | grep 192.168.56 | awk '{print $(NF)}')
	else
		return 0
	fi
}

function login () {

	if [[ "$(cat ~/.docker/config.json | grep ${PRIVATEREGISTRY})" ]]; then
		return 0
	else
		printf "You need to login on the registry ${PRIVATEREGISTRY}.\n"
		printf "docker login ${PRIVATEREGISTRY}\n"
		printf "Please, type the your username and password. They are the same as bk-inside"
		docker login ${PRIVATEREGISTRY}
	fi
	
}

function removeAll () {

	printf "This will remove all stack components (stack, network, volume)\n"
	printf "Are you sure you want to proceed? (y/N)\n"
	read -r ANSWER

	if [[ ${ANSWER} == "y" || ${ANSWER} == "Y" ]]; then
		printf "Stopping the stack\n"
        	docker stack rm dev
		printf "Removing the network\n"
       		docker network rm ingress
		printf "Removing the volume\n"
        	docker volume rm db-dev
	else
		printf "Procedure cancelled.\n"
	fi

}

function network () {

	if [[ "$(docker network inspect ingress)" ]]; then
		printf "Network already exists\n"
	else
		printf "Creating the network 'ingress'\n"
 	        docker network create --ingress --driver overlay ingress
	fi

}

function volume () {

	if docker volume ls | grep -q 'db-dev'; then
		printf "Volume already exists\n"
	else
		printf "Creating the volume db-dev\n"
         	docker volume create db-dev
	fi

}

function reloadStack () {

	printf "Reloading the stack\n"
	docker stack deploy --with-registry-auth -c docker-stack.yml dev

}

function startStack () {

	if grep -q ${PRIVATEREGISTRY} ~/.docker/config.json; then
		printf "Starting the stack dev\n"
		docker stack deploy -c docker-stack.yml dev
	else
		login
	fi
		
}

function stopStack () {

	printf "Stopping the stack dev\n"
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
