#!/bin/bash

SLEEP=5

case "${HOSTNAME}" in
    "k1")
# k1 swarm managers
	MANAGERS="
	wrk201
	wrk221
	wrk241
	"
	;;
    "k2")
# k2 swarm managers
	MANAGERS="
	wrk131
	wrk151
	wrk171
	"
	;;
    *)    MANAGERS="Default";;
esac

for HOST in ${MANAGERS}
do

  MYCMD="VBoxManage modifyvm ${HOST} --cpus 2 --memory 4000"
  echo "I will stop ${HOST} in ${SLEEP} seconds. Than that I will run: ${MYCMD} and restart it."

  sleep ${SLEEP}
  echo "Stopping ${HOST} ..."
  docker-machine stop ${HOST}
  echo "If cant stop, try killing ${HOST} ..."
  docker-machine kill ${HOST}

  sleep ${SLEEP}
  echo "Runnig: ${MYCMD}"
  ${MYCMD}

  sleep ${SLEEP}
  echo "Starting ${HOST} with new settings..."
  docker-machine start ${HOST}
done
