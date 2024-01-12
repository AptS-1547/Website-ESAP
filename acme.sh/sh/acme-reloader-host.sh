#!/bin/bash

function restart_with() {
	$1 > /tmp/acme-reloader.log 2>&1
	if [[ ! $? == "0" ]]
	then
		echo "[`date '+%x %T'` acme-reloader-host] An error occurred while executing the command. Please check the"
		echo "[`date '+%x %T'` acme-reloader-host] /tmp/acme-reloader.log file for more information."
		echo error >> /tmp/acme-reloader/acme-reloader.sock
		rm -f /tmp/acme-reloader/acme-reloader.sock
		exit 1
	fi
}

function restart_command() {
	#Please place the command you want acme.sh to run on the host
	#after obtaining the certificate here.
	
	restart_with "docker restart nginx-website mailserver"
	
	
	#Input completed, please do not change other files and enjoy your automated operation :)
	echo "Complete" >> /tmp/acme-reloader/acme-reloader.sock
}

trap 'onCtrlC' INT
function onCtrlC() {
	rm -f /tmp/acme-reloader/acme-reloader.sock
	echo "[`date '+%x %T'` acme-reloader-host] Exiting"
	exit 0
}

rm -f /tmp/acme-reloader/acme-reloader.sock
mknod /tmp/acme-reloader/acme-reloader.sock p
if [[ $? == "0" ]]
then
	echo "[`date '+%x %T'` acme-reloader-host] acme-reloader-host Started."
else 
	echo "[`date '+%x %T'` acme-reloader-host] Unable to create /tmp/acme-reloader/acme-reloader.sock file. Please check your permissions in the /tmp folder."
	exit 1
fi

while true
do
	export receive_message="`cat /tmp/acme-reloader/acme-reloader.sock`"
	if [[ ${receive_message} == "restart" ]]
	then
		echo "[`date '+%x %T'` acme-reloader-host] Received overload request from acme.sh container, executing overload command..."
		restart_command
	fi
	sleep 1
done

