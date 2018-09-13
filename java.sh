##########################################
# This is a simple start up/stop/restart #
# to execute a jar file                  #
##########################################

#!/bin/bash
start() {

    java -Djava.net.preferIPv4Stack=true -jar /opt/*.jar &

}

stop() {

    pid=`ps aux | grep demo | grep -v grep |awk '{print $2}'`
    if [ "" != "$pid" ]; then
     kill -15 $pid
    fi

}

case $1 in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    *)

        echo $"Usage: $0 {start|stop|restart}"
        exit 1
esac
exit 0
