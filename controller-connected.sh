#!/bin/bash

PC_IP_ADDRESS="192.168.0.120"
PC_MAC_ADDRESS="E8:FB:1C:D4:9A:71"
LOCKFILE="controller-connected.lock"
LOGFILE="/var/log/xbox-controller.log"
START_MOONLIGHT_SCRIPT="./moonlight-background.sh"

# Lock, it's used to make sure the script will be executed only once at short period of time
if [ -e $LOCKFILE ]; then
    exit 0
fi
touch $LOCKFILE

echo "$(date): Controller connected" >> $LOGFILE

# Wake a PC, it's already running it does nothing anyway
echo "$(date): Waking up $PC_MAC_ADDRESS" >> $LOGFILE
etherwake $PC_MAC_ADDRESS >> $LOGFILE

# Function to check if ping is successful
check_ping() {
    ping -c 1 $PC_IP_ADDRESS > /dev/null 2>&1
    return $?
}

# Wait until ping is successful
while ! check_ping; do
    echo "$(date): Waiting for $PC_IP_ADDRESS to respond..." >> $LOGFILE
    sleep 2
done

echo "$(date): $PC_IP_ADDRESS is now reachable!" >> $LOGFILE

echo "$(date): Waiting for $PC_IP_ADDRESS until it's ready for streaming..." >> $LOGFILE
sleep 4

# Check if any process with the name "moonlight-qt" is running and store the result in a variable
MOONLIGHT_RUNNING=$(pgrep -x moonlight-qt > /dev/null && echo true || echo false)

# Run the custom script if the controller is present and moonlight-qt is not running
if [ "$MOONLIGHT_RUNNING" = "false" ]; then
    echo "$(date): moonlight-qt is starting..." >> $LOGFILE
    $START_MOONLIGHT_SCRIPT
else
    echo "$(date): moonlight-qt is already running" >> $LOGFILE
fi

rm $LOCKFILE
echo "$(date): Realising a lock" >> $LOGFILE