#!/bin/bash

docker run -d -p 55555:55555 \
	-v /var/lib/mnt-btsync/worlds:/worlds \
	-e btfs_use_tracker='false' \
      	-e btfs_use_relay_server='false' \
 ekellener/btsync-test /worlds AP3WYXGCTXJDODBQHQEWVHCPSW7RTERWJ
