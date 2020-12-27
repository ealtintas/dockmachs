#!/bin/bash

# PURPOSE:
# - Check if a docker-machine is unresposive, if so forcefully reboot it

set -x 

source "./dm-settings.sh"

MYNAME=$1
shift

echo "### Check $MYNAME and reboot if necessary"
REBOOTME=False
MYSTATUS=$(docker-machine status $MYNAME)
echo "STATUS of $MYNAME is: $MYSTATUS"
#MYIP="FAIL"

if [ $MYSTATUS == "Running" ]
then
  echo "$MYNAME seems $MYSTATUS trying to get its IP adress"
  MYIP=$(docker-machine ip $MYNAME) & sleep 10
  EXITCODE=$?
fi

echo $EXITCODE
echo $MYIP ; sleep 30
echo $EXITCODE

if [ $MYIP == "FAIL" ]
then
  echo "FAILED: $MYNAME seems $MYSTATUS bu its IP address is not available, we should reboot it"  # Fail
  REBOOTME=True
else
  echo "IP of $MYNAME is: $MYSTATUS"  # Success
fi

# MYPUBIP="FAIL"
# MYPUBIP=$(docker-machine ssh $MYNAME "curl -s ifconfig.me")
# echo "PUBIP of $MYNAME is: $MYSTATUS"

if [ $REBOOTME == True ]
then
  echo "Try gracefull stop for $MYNAME" &
  docker-machine stop $MYNAME & sleep 10
  echo "Now, try forcefully killing $MYNAME"
  docker-machine kill $MYNAME ; sleep 5
  echo "Restarting $MYNAME"
  docker-machine start $MYNAME & sleep 10
else
  echo "$MYNAME seems OK (Status: $MYSTATUS IP: $MYIP), I will not reboot it."  # Success
  exit
fi
