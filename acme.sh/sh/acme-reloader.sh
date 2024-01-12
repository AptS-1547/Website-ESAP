#!/bin/bash

ls /tmp/acme-reloader/acme-reloader.sock > /dev/null 2>&1
if [ ! $? == "0" ]
then
	echo "[`date '+%x %T'` acme-reloader] Host error: Unable to connect to host."
	echo "[`date '+%x %T'` acme-reloader] Please check if the host has started acme-reloader-host.sh"
	echo "[`date '+%x %T'` acme-reloader] and if the /tmp/acme-reloader directory is mounted."
	exit 1
fi

echo restart >> /tmp/acme-reloader/acme-reloader.sock
echo "[`date '+%x %T'` acme-reloader] Ok, Host got the restart message."
sleep 5

export return_value="`cat /tmp/acme-reloader/acme-reloader.sock`"

if [[ ${return_value} == "Complete" ]]
then
	echo "[`date '+%x %T'` acme-reloader] Restart Complete"
	exit 0
else
	echo "[`date '+%x %T'` acme-reloader] An error occurred while executing the command. Please check the"
	echo "[`date '+%x %T'` acme-reloader] /tmp/acme-reloader.log on the Host for more information."
	exit 1
fi
