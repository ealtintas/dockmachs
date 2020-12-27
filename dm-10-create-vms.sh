#!/bin/bash
# REFS:
# - https://github.com/blueimp/shell-scripts/blob/df2eaf79ad7935bfb4b6d5834895d4912d6df4ea/bin/docker-machine-bridge.sh

#set -x

source "./dm-settings.sh"

VBoxManage setproperty autostartdbpath /etc/virtualbox-autostart/

for IND in $(seq -f "%03g" ${START} ${END})
do
	MYNAME="${PREFIX}${IND}"
	echo "Machine name: ${MYNAME}"

	sleep 1

	docker-machine create \
	  --driver virtualbox \
	  --virtualbox-cpu-count 1 \
	  --virtualbox-memory 1024 \
	  --virtualbox-hostonly-cidr "192.168.100.1/24" \
	  ${MYNAME} &
#	     --virtualbox-disk-size "5120" #                                                                     Size of disk for host in MB [$VIRTUALBOX_DISK_SIZE] \
#	  ${MYNAME} &	#  background running causes same dynamic-ip problems

	sleep 0.1

	VBoxManage modifyvm ${MYNAME} --nic3 bridged --bridgeadapter3 eno1 --nictype3 82540EM
	VBoxManage modifyvm ${MYNAME} --nic4 bridged --bridgeadapter4 eno4 --nictype4 82540EM
    VBoxManage modifyvm ${MYNAME} --autostart-enabled on

done

echo "DONE"

#docker-machine ls


