#!/bin/bash
# REFS:
# - https://github.com/blueimp/shell-scripts/blob/df2eaf79ad7935bfb4b6d5834895d4912d6df4ea/bin/docker-machine-bridge.sh
# - https://github.com/boot2docker/boot2docker/blob/master/files/bootsync.sh

set -x

source "./dm-settings.sh"

for IND in $(seq -f "%03g" ${START} ${END})
do
	MYNAME="${PREFIX}${IND}"
	echo "Machine name: ${MYNAME}"

	MYLOCALIP="192.168.100.${IND}"
        MYSWARMIP="192.168.101.${IND}"
	MYPUBLICIP="213.142.135.${IND}"

#	/root/bin/dm-bridge.sh -i eno1 ${MYNAME}
#       /root/bin/dm-add-swarm-interfece-eth3.sh

##	/root/bin/dm-static-ip.sh --ip ${MYLOCALIP} ${MYNAME}
##        sleep 1

##        /root/bin/dm-set-eth3.sh --ip ${MYSWARMIP} ${MYNAME}
##        sleep 1

BOOTSYNC_SH_PATH="/var/lib/boot2docker/bootsync.sh"
BOOTSYNC_SH_CONTENT="#!/bin/sh
### stop dhcp ###
/etc/init.d/services/dhcp stop
### set static ip ###
ifconfig eth1 ${MYLOCALIP} netmask 255.255.255.0 broadcast 192.168.100.255 up
### set swarm ip ####
ifconfig eth3 ${MYSWARMIP} netmask 255.255.255.0 broadcast 192.168.101.255 up
### set public ip ###
ifconfig eth2 ${MYPUBLICIP} netmask ${MYNETMASK} up
### set route ###
sudo route del default gw 10.0.2.2
sudo route add default gw ${MYGATEWAY}"

	docker-machine ssh ${MYNAME} "echo -e \"$BOOTSYNC_SH_CONTENT\" | sudo tee ${BOOTSYNC_SH_PATH} > /dev/null && sudo chmod 755 ${BOOTSYNC_SH_PATH}"
        sleep 0.1

#        docker-machine regenerate-certs -y ${MYNAME}
#        sleep 1

#	docker-machine restart ${MYNAME} & # restart in the backgroud for the changes to be effective
#	sleep 1
	echo ${MYNAME} >> ${MACHINESFILE}
done

echo "DONE"

echo "Dont forget to check the rebooted machines which are from ${PREFIX}${START} to ${PREFIX}${END}"

exit

docker-machine regenerate-certs $(./dm-all.sh list)
