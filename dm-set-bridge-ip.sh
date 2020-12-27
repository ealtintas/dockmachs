#!/bin/bash
# REFS:
# - https://github.com/blueimp/shell-scripts/blob/df2eaf79ad7935bfb4b6d5834895d4912d6df4ea/bin/docker-machine-bridge.sh

#set -x

source "./dm-settings.sh"

for IND in $(seq -f "%03g" ${START} ${END})
do
	MYNAME="${PREFIX}${IND}"
	echo "Machine name: ${MYNAME}"

	MYIP="213.142.135.${IND}"

	./dm-bridge.sh -i eno1 ${MYNAME}

	docker-machine ssh ${MYNAME} "sudo ifconfig eth2 ${MYIP} up; sudo ifconfig eth2 netmask ${MYNETMASK} ; sudo route del default gw 10.0.2.2 ; sudo route add default gw ${MYGATEWAY}"
#sudo ip route add default via ${MYGATEWAY}
	./dm-bridge.sh ${MYNAME}

	docker-machine ssh ${MYNAME} "curl https://ifconfig.me/"

	echo ${MYNAME} >> ${MACHINESFILE}

done

echo "DONE"

exit

