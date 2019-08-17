#!/bin/bash

usage() {
	echo -n "functions [OPTION]

Script to start and stop the docker stack.

 Options:
  -h      Show this help menu
  start   Start the stack
  stop    Stop the stack
"
}

function network() {
	if [ -z "`docker network ls | grep leandro`" ]; then
		printf "Network already exists"
		exit 0
	else
		echo "Creating the network 'leandro'"
 	        docker network create leandro
	fi
}

function volume () {
	if [ -z "`docker volume ls | grep db-dev`"]; then
		printf "Volume already exists"
		exit 0
	else
		echo "Creating the volume db-dev"
         	docker volume create db-dev
	fi
}

#while [[ $1 = -?* ]]; do
	case "$1" in
		start)
			echo "Start"
			network >&2;
			volume
		        ;;
		stop)
			echo "Stop"
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
#done

