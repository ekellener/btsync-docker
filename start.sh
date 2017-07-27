#!/bin/bash
#
# Example of swarm service creation
#  --constraint 'node.role == manager' \
# --mode global \
#docker service create \
# --name btsync-docker-worlds \
# --env  btsf_use_tracker='false' \
# --env  btsf_use_relay_server='false' \
# --env  btdf_use_relay='false' \
# --env  btdf_use_tracker='false' \
# --publish 55555:55555 \
# --mount "type=bind,source=/var/lib/mnt_btsync/worlds,destination=/worlds" \
# --mode global \
#  ekellener/btsync-docker-multi /worlds AP3WYXGCTXJDODBQHQEWVHCPSW7RTERWJ

#       -e btfs_use_tracker='false' \
#        -e btfs_use_relay_server='false' \

docker run -d -p 55555:55555 \
	-v /var/lib/mnt-btsync/worlds:/worlds \
       -e btfs_use_tracker='false' \
        -e btfs_use_relay_server='false' \
 ekellener/btsync-docker /worlds AP3WYXGCTXJDODBQHQEWVHCPSW7RTERWJ
