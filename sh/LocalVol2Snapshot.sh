#!/bin/bash

# Usage:LocalVol2Snapshot.sh /dev/sda1 "message"

InstanceID=`curl http://169.254.169.254/latest/meta-data/instance-id`
DeviceName=$1

GetVolID(){
	aws ec2 describe-instance-attribute \
		--region ap-northeast-1 \
		--instance-id ${InstanceID} \
		--attribute blockDeviceMapping \
		| jq -r '.BlockDeviceMappings[] |select(.DeviceName == "'${DeviceName}'") |.Ebs | .VolumeId'
}

GetSnapshot(){
	aws ec2 create-snapshot \
		--region ap-northeast-1 \
		--volume-id $1 \
		--description "$2"
	return $?
}

# Get VolumeID of EBS from the device name of the Local.
VolumeID=$(GetVolID)
if [ "${VolumeID}" = "" ] ;then
	echo "VolumeID could not be found."
	exit 2
fi

# Get Snapshot.
GetSnapshot ${VolumeID} "$2"
exit $?
