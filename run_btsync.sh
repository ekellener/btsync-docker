#!/bin/bash

#Set defaults

env >>/tmp/log.txt

# Parameters being passed $1 = Dir and $2 Secret
if [ "$#" -eq 2 ]
then
# Add Directory
echo "Adding dir" $1 >>/tmp/log.txt
cm="jq '.shared_folders[0] |= .+{\"dir\": \"$1\"}' config.json > config.tmp "
eval $cm
cat config.tmp >>/tmp/log.txt
cp config.tmp config.json
echo "Adding secret" $2 >>/tmp/log.txt
cm=" jq '.shared_folders[0] |= .+{\"secret\": \"$2\"}' config.json > config.tmp "
eval $cm
cat config.tmp >>/tmp/log.txt
cp config.tmp config.json

#Set device name default to hostname
echo "Adding Hostname" $HOSTNAME >>/tmp/log.txt
cm="jq '. |= .+{\"device_name\": \"btsync-$HOSTNAME\"}' config.json > config.tmp "
eval $cm
cp config.tmp config.json

fi

btprefix="bt_"
btsfprefix="btsf_"
btdfprefix="btdf_"
while IFS='=' read -r -d '' n v; do
   if [[ "$n" == "$btprefix"* ]] ; then
     echo "Need to change": $n "to " $v >> /tmp/log.txt;	
    cm=" jq '. |= .+{${n#$btprefix}: $v}' config.json > config.tmp "
    eval $cm
    cat config.tmp >>/tmp/log.txt
    cp config.tmp config.json
    fi

if [[ "$n" == "$btsfprefix"* ]] ; then
     echo "Need to change in Shared Folders": $n "to " $v >> /tmp/log.txt ;       
     cm=" jq '.shared_folders[0] |= .+{${n#$btsfprefix}: $v}'  config.json >config.tmp "
    eval $cm 
    cat config.tmp >>/tmp/log.txt
    cp config.tmp config.json
    fi

if [[ "$n" == "$btdfprefix"* ]] ; then
     echo "Need to change in default Folders": $n "to " $v >> /tmp/log.txt ;       
     cm=" jq '.+{\"folder_defaults.${n#$btdfprefix}\": $v}'  config.json >config.tmp "
    eval $cm 
    echo $cm >>tmp/log.txt
    cat config.tmp >>/tmp/log.txt
    cp config.tmp config.json
    fi



done < <(env -0)

exec btsync --config /btsync/config.json --nodaemon

