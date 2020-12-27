#!/bin/sh

eval $(docker-machine env --unset)
exit

eval unset DOCKER_TLS_VERIFY
unset DOCKER_HOST
unset DOCKER_CERT_PATH
unset DOCKER_MACHINE_NAME
# Run this command to configure your shell: 
# eval $(docker-machine env --unset)
