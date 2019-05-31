#!/bin/sh
#Runs through AWS account and outputs IAM access keys
for user in $(aws iam list-users --output text | awk '{print $NF}'); do
    aws iam list-access-keys --user $user --output text
done
