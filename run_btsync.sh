#!/bin/bash

#Set defaults

# Parameters being passed $1 = Dir and $2 Secret

if [ "$#" -eq 2 ]
then
# Add Directory
cm="jq '.shared_folders[0] |= .+{\"dir\": \"$1\"}' config.json > config.tmp "
eval $cm
cp config.tmp config.json

cm=" jq '.shared_folders[0] |= .+{\"secret\": \"$2\"}' config.json > config.tmp "
eval $cm
cp config.tmp config.json

#Set device name default to hostname
cm="jq '. |= .+{\"device_name\": \"btsync-$HOSTNAME\"}' config.json > config.tmp "
eval $cm
cp config.tmp config.json


fi

btprefix="bt_"
btsfprefix="btsf_"
while IFS='=' read -r -d '' n v; do
   if [[ "$n" == "$btprefix"* ]] ; then
     echo "Need to change": $n "to " $v ;	
    cm=" jq '. |= .+{${n#$btprefix}: $v}' config.json > config.tmp "
    eval $cm
    cp config.tmp config.json
    fi

if [[ "$n" == "$btsfprefix"* ]] ; then
     echo "Need to change in Shared Folders": $n "to " $v ;       
     cm=" jq '.shared_folders[0] |= .+{${n#$btsfprefix}: $v}'  config.json >config.tmp "
    eval $cm 
    cp config.tmp config.json
    fi

done < <(env -0)

exec btsync --config /btsync/config.json --nodaemon


#jq '. |= .+{listening_port: 5555}'  test.json
