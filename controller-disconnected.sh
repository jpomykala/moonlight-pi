#!/bin/bash

LOCKFILE="controller-disconnected.lock"
LOGFILE="/var/log/xbox-controller.log"

if [ -e $LOCKFILE ]; then
    exit 0
fi
touch $LOCKFILE

echo "$(date): Controller disconnected" >> $LOGFILE
./moonlight-kill.sh
echo "$(date): moonlight-qt terminated" >> $LOGFILE
sleep 2
rm $LOCKFILE
rm controller-connected.lock
echo "$(date): Realising locks" >> $LOGFILE
