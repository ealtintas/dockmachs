#!/bin/bash

prog=$0
path=$(dirname $prog)
base=$(basename $prog)

source "./dm-settings.sh"

# PURPOSE: do some action (start, stop etc...) on all docker machines together
# TODO:
# - Check unresponsive docker-machines and restart them forcefully
# REFS:
# - https://stackoverflow.com/questions/32531870/docker-machine-stop-command-kills-all-my-containers
# - https://stackoverflow.com/questions/37069718/docker-machine-timeout-how-to-fix-without-destroying-the-machine

# Pause
#VBoxManage controlvm YOURDOCKERMACHINENAME savestate
# To resume:
#docker-machine start YOURDOCKERMACHINENAME && eval $(docker-machine env YOURDOCKERMACHINENAME)
# Stop All docker machines
#docker-machine stop $(docker-machine ls --format "{{.Name}}")
# Start All docker machines
#docker-machine start $(docker-machine ls --format "{{.Name}}")

do_help() {
	cat <<END
$base - helps you manages all docker-machines at once

Syntax: $base [ <command> ] [ <options> ]

You can use docker-machine like command for all the machines easily:

	status
	stop
	start
	rm
	ip
	pubip
	restart
	ssh

and additional commands:

END
}

function heal_docker_machine() 
{
	DM=$1

	RUNCMD="free -m | grep ^Mem: ; sudo df -h | grep docker ; sudo dd if=/dev/zero bs=1 count=1 of=/mnt/sda1/var/lib/boot2docker/log/docker.log ; docker system prune --force ; free -m | grep ^Mem: ; sudo df -h | grep docker"
	OUTPUT=$(docker-machine ssh $DM $RUNCMD)
	echo "################################################################################# >>> START: $DM >>>"
	echo "$OUTPUT"
	echo "################################################################################# <<< END  : $DM <<<"
	if [[ "$OUTPUT" == "" ]]; then
		DM_ERR="$DM_ERR $DM"
		echo "!!! Repairing: $DM"
		# doker-machine restart $DM	& 	sleep 5
		docker-machine stop $DM 	&	sleep 20
		docker-machine kill $DM 	;	sleep 0.5
		docker-machine start $DM 	& 	sleep 3
	else
		DM_WRK="$DM_WRK $DM"
	fi

}

cmd=$1 ; shift || true
case "$cmd" in

    status)
#		ALLDMS=$(docker-machine ls --format "{{.Name}}")
		ALLDMS=$(docker-machine ls --quiet)
		for DM in $ALLDMS
		do 
		  echo "$DM - $(docker-machine status $DM)"
#		  echo "$DM - $(docker-machine status $DM) - $(docker-machine ip $DM)"
		done  
	exit $?
	;;

    ip)
		ALLDMS=$(docker-machine ls --quiet)
		for DM in $ALLDMS
		do 
		  echo "$DM - $(docker-machine ip $DM)" &
                  sleep 0.5
		done
	exit $?
	;;

    pubip)
		ALLDMS=$(docker-machine ls --quiet)
		for DM in $ALLDMS
		do 
		  echo "$DM - $(docker-machine ssh $DM 'curl -s ifconfig.me')" &
                  sleep 0.5
		done  
	exit $?
	;;

    rm|remove)
		ALLDMS=$(docker-machine ls --quiet)
		docker-machine rm $ALLDMS
	exit $?
	;;

    ls|list)
		ALLDMS=$(docker-machine ls --quiet)
		echo $ALLDMS
	exit $?
	;;

    ssh)
		ALLDMS=$(docker-machine ls --quiet)
		for DM in $ALLDMS
		do 
		  echo "### Machine: $DM ###"
		  docker-machine ssh $DM $@ &
		  sleep 3
		done  
	exit $?
	;;

    ssh-oneline)
		ALLDMS=$(docker-machine ls --quiet)
		for DM in $ALLDMS
		do 
			OUTPUT=$(docker-machine ssh $DM $@)
			echo "$DM: $OUTPUT"
		done  
    exit $?
	;;

    uptime)
		ALLDMS=$(docker-machine ls --quiet)
		DM_ERR=""
		DM_WRK=""
		for DM in $ALLDMS
		do 
			OUTPUT=$(docker-machine ssh $DM uptime)
			echo "$DM: $OUTPUT"
			if [[ "$OUTPUT" == "" ]]; then
				DM_ERR="$DM_ERR $DM"
			else
				DM_WRK="$DM_WRK $DM"

			fi
		done
		echo "Worked on machines: $DM_WRK"
		if [[ "$DM_ERR" != "" ]]; then
			echo "Errors on machines: $DM_ERR"
		fi
    exit $?
	;;

    heal)
		ALLDMS=$(docker-machine ls --quiet)
		DM_ERR=""
		DM_WRK=""
		DOWNDMS=$(docker node ls | grep Down | cut -d' ' -f6)
		echo "Down DMS: $DOWNDMS"
		for DM in $ALLDMS
#		for DM in $DOWNDMS
		do 
			heal_docker_machine $DM
		done
		echo "Healty machines: $DM_WRK"
		if [[ "$DM_ERR" != "" ]]; then
			echo "Try healing repaired machines: $DM_ERR"
			for DM in $DM_ERR
			do 
				heal_docker_machine $DM
			done
		fi
    exit $?
	;;
	
    repair)
		ALLDMS=$(docker-machine ls --quiet)
		DM_ERR=""
		DM_WRK=""
		for DM in $ALLDMS
		do 
			OUTPUT=$(docker-machine ssh $DM uptime)
			echo "$DM: $OUTPUT"
			if [[ "$OUTPUT" == "" ]]; then
				DM_ERR="$DM_ERR $DM"
				echo "!!! Repairing: $DM"
				# doker-machine restart $DM	& 	sleep 5
				docker-machine stop $DM 	&	sleep 60
				docker-machine kill $DM 	;	sleep 0.5
				docker-machine start $DM 	& 	sleep 5
			else
				DM_WRK="$DM_WRK $DM"
			fi
		done
		echo "Healty machines: $DM_WRK"
		if [[ "$DM_ERR" != "" ]]; then
			echo "Repaired machines: $DM_ERR"
		fi
    exit $?
	;;

    stop)
		ALLDMS=$(docker-machine ls --quiet)

		for DM in $ALLDMS
		do 
			echo "Processing: $DM"
			docker-machine stop $DM &
			sleep 2
		done  
	exit $?
	;;

    start)
		ALLDMS=$(docker-machine ls --quiet)

		for DM in $ALLDMS
		do 
			echo "Processing: $DM"
			docker-machine start $DM &
			sleep 1
		done  
	exit $?
	;;

    restart)
		ALLDMS=$(docker-machine ls --quiet)

		for DM in $ALLDMS
		do 
			echo "Processing: $DM"
			# doker-machine restart $DM &
			# sleep 5
			docker-machine stop $DM
			sleep 0.5
			docker-machine kill $DM
			sleep 0.5
			docker-machine start $DM &
			sleep 4
		done  
	exit $?
	;;

	scp)
		ALLDMS=$(docker-machine ls --quiet)

		for DM in $ALLDMS
		do 
		  echo "Processing: $DM"
		  docker-machine scp $DM $1 $2	# SAMPLE: dm-all scp ~/.docker/config.json ~/.docker/config.json
          sleep 0.1
		done  
	exit $?
	;;

    copyfile)
		ALLDMS=$(docker-machine ls --quiet)

		for DM in $ALLDMS
		do 
		  echo "Processing: $DM"
		  cat $1 | docker-machine ssh $DM "tee $2"	# SAMPLE: cat wrk131-docker-config.json | docker-machine ssh wrk130 "tee ~/.docker/config.json"
          sleep 0.1
		done  
	exit $?
	;;

    *)
	do_help
	exit $?
	;;
esac
exit 1
