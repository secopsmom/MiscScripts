#!/bin/sh
#Outputs all CMK and Managed keys.
for region in $(aws ec2 describe-regions --output text | cut -f3); do
	for keyid in $(aws kms list-keys --region $region --output text | awk '{print $NF}'); do
		alias=$(aws kms list-aliases --region $region --key-id $keyid --output text | cut -f3)
		status=$(aws kms describe-key --region $region --key-id $keyid --output text | cut -f9)
		principle=$aws kms get-key-policy --region $region --key-id $keyid --policy-name default  --output text | jq -c '.Statement[].Principal.AWS' | sed 's/[][{}]//g'| sed 's/,/\\n/g' | sort -u)
	echo "KMS Alias Name: $alias\nKeyID: $keyid\nRegion: $region\nStatus: $status\nPrinciple:\n$principle\n\n"
	done
done
