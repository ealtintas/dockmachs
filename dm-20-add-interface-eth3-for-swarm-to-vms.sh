#!/bin/bash

set -x

source "./dm-settings.sh"

NETWORK_ADAPTER=eno4

for IND in $(seq -f "%03g" ${START} ${END})
do
	MYNAME="${PREFIX}${IND}"
	echo "Machine name: ${MYNAME}"

	docker-machine stop ${MYNAME}

	sleep 1

	VBoxManage modifyvm ${MYNAME} \
	  --nic4 bridged \
	  --nictype4 82540EM \
	  --bridgeadapter4 "$NETWORK_ADAPTER"

	sleep 1

done

echo "DONE"

exit
