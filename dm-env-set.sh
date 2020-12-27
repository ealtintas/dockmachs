#!/bin/sh

# REFS:
# - https://gist.github.com/skatsuta/392d3cd251dd468b75c7
# - https://riptutorial.com/docker/example/11080/list-docker-machines

echo "Enumerating docker-machine swarm managers..."
# check if `docker-machine` command exists
if command -v docker-machine > /dev/null; then
  # fetch the first running machine name
##  local machine=$(docker-machine ls | grep "Running" | head -n 1 | awk '{ print $1 }')
##  MANAGER="wrk201"
  MANAGER=$(docker-machine ls --quiet --filter state=running | grep -E "wrk201|wrk202|wrk203" | head -n 1)
  if [ "$MANAGER" != "" ]; then
    eval $(docker-machine env $MANAGER)
    echo "Docker swarm manager set to: $MANAGER"
  fi
fi

docker node ls

#export DOCKER_TLS_VERIFY="1"
#export DOCKER_HOST="tcp://192.168.100.201:2376"
#export DOCKER_CERT_PATH="/root/.docker/machine/machines/wrk201"
#export DOCKER_MACHINE_NAME="wrk201"
## Run this command to configure your shell: 
## eval $(docker-machine env wrk201)

#run-parts $HOME/.config/bash/
