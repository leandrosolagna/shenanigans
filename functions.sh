#!/bin/bash

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

function remove-all () {

	printf "This will remove all stack components (stack, network, volume)\n"
	printf "Are you sure you want to proceed? (y/N)"
	if ; then
	else
	fi
	printf "Stopping the stack\n"
        docker stack rm dev
	printf "Removing the network\n"
        docker network rm leandro
	printf "Removing the volume\n"
        docker volume rm db-dev

}

function network () {

	if [[ "`docker network inspect leandro`"  ]]; then
		printf "Network already exists\n"
	else
		printf "Creating the network 'leandro'\n"
 	        docker network create leandro
	fi

}

function volume () {

	if [[ "`docker volume ls | grep db-dev`" ]]; then
		printf "Volume already exists\n"
		exit 0
	else
		printf "Creating the volume db-dev\n"
         	docker volume create db-dev
	fi

}

function reload-stack () {

	printf "Reloading the stack\n"
        docker stack deploy -c docker-stack.yml dev

}

function start-stack () {

	printf "Starting the stack dev\n"
	docker stack deploy -c docker-stack.yml dev

}

function stop-stack () {

	printf "Stopping the stack dev\n"
	docker stack rm dev

}

case "$1" in
	start)
		network >&2;
		volume
		start-stack
		exit 0
		;;

	stop)
		stop-stack
		exit 0
	        ;;

	reload)
		reload-stack
		exit 0
		;;
		
	remove)
		remove-all
		exit 0
		;;

	-h) 
		usage >&2;
		exit 0
		;;
	
        *|-*)
	        echo ""	
		echo "Invalid option: '$1'."
		usage >&2
	        exit 2
		break
		;;
esac
