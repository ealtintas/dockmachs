#!/bin/sh
# PURPOSE: 
# - Heal docker-machines periodically
# HOWTO:
# - Adjust SLEEP and run manually in a tmux session 
# TODO:
# - check readonly mount => dm-all.sh ssh-oneline "mount | grep '(ro,'"

SLEEP=600
MYLOG="/var/log/CUSTOM/output_dm-maintain_$(mytime).txt"

while true
do
    echo "### $(mytime): Start healing..." | tee $MYLOG;
    dm-all.sh heal | tee $MYLOG;
    echo "### $(mytime): Sleeping $SLEEP seconds..." | tee $MYLOG; sleep $SLEEP; 
done