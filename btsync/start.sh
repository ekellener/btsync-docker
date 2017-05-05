#!/bin/bash

nodejs btsync.js init

if [ "$#" -eq 2 ]
then
	nodejs btsync.js add-folder $1 $2
fi

# Changed to stop instead of restart so start can run inline
nodejs btsync.js stop

exec btsync --config /btsync/config --nodaemon
