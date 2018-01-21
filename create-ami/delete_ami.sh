#!/bin/bash

AMI_NAME=$1

echo -n "Checking if an AMI '$AMI_NAME' already exists... "
AMIS=$( aws ec2 describe-images --owner self --filters Name=name,Values="$AMI_NAME" )
if [ $( echo "$AMIS" | jq '.Images | length' ) -ne "0" ]; then
	AMI_ID=$( echo "$AMIS" | jq --raw-output '.Images[0].ImageId' )
	echo "yes, $AMI_ID"
	echo "Deregistering that AMI..."
	aws ec2 deregister-image --image-id $AMI_ID
	echo "Deleting AMI's backing Snapshot..."
	aws ec2 delete-snapshot --snapshot-id $( echo "$AMIS" | jq --raw-output '.Images[0].BlockDeviceMappings[0].Ebs.SnapshotId' )
else
	echo "no"
fi