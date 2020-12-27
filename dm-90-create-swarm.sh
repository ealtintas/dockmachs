#!/bin/bash
# REFS:
# - https://github.com/BretFisher/dogvscat/blob/48ad879e0b2b12e719919070014c89df6523e307/create-swarm.sh
#set -x
# TODO:
# - Read PREFIX, START, END from files in current dir
# - Create N managers

source "./dm-settings.sh"

LEADER_NAME="${PREFIX}${LEADER_IND}"
# use private NIC on eth1 that for swarm communication
LEADER_IP=$(docker-machine ssh ${LEADER_NAME} ifconfig eth1 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')
echo "Create swarm leader: ${LEADER_NAME} ip: ${LEADER_IP}"
# create a swarm managers
docker-machine ssh ${LEADER_NAME} docker swarm init --advertise-addr "${LEADER_IP}"

docker-machine ssh ${LEADER_NAME} docker swarm update --task-history-limit=1

# note that if you use eth1 above (private network in digitalocean) it makes the below # a bit tricky, because docker-machine lists the public IP's but we need the private IP of manager for join commands, so we can't simply envvar the token # like lots of scripts do... we'd need to fist get private IP of first node
JOIN_TOKEN=$(docker-machine ssh ${LEADER_NAME} docker swarm join-token -q worker)

for IND in $(seq -f "%03g" ${START} ${END})
do
	MYNAME="${PREFIX}${IND}"
	echo "Machine name: ${MYNAME}"

	echo "Joining ${MYNAME}"
	docker-machine ssh ${MYNAME} docker swarm join --token "${JOIN_TOKEN}" "${LEADER_IP}":2377

	echo ${MYNAME} >> ${MACHINESFILE}
        sleep 1
done



echo "DONE"

echo "To run docker commands in the cluster use below:"
docker-machine env ${LEADER_NAME}
