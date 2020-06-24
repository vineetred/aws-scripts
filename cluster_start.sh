#!/bin/bash

#description     :This script will start a ECS cluster and deploy the brain inference Docker image
#author		       :vineetred
#date            :20200620
#version         :0.2   

echo "
█▀▀ █░░ █░█ █▀ ▀█▀ █▀▀ █▀█   █▀ ▀█▀ ▄▀█ █▀█ ▀█▀
█▄▄ █▄▄ █▄█ ▄█ ░█░ ██▄ █▀▄   ▄█ ░█░ █▀█ █▀▄ ░█░"
echo


if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` <PROJECT-NAME> <CLUSTER-CONFIG> <ECS-PROFILE> <REGION-CODE>"
  echo "Accepted region format - eu-west-2"
  echo "Refer to https://docs.aws.amazon.com/general/latest/gr/rande.html for correct codes"
 echo
 echo "Make sure you see README.md"
  exit 1
fi

if [ $# -le 3 ]
  then
    echo "No arguments supplied/Missing args"
    exit 1
fi

echo PROJECT NAME - $1
echo CLUSTER CONFIG - $2
echo ECS PROFILE - $3
echo AWS REGION - $4
echo 
read -p "Are these details correct? [Yy]"
echo 

if [[ $REPLY =~ ^[Yy]$ ]]
	then
        # First, generate a configiration for the ECS cluster
        echo "Config generation"
        ecs-cli configure --cluster $2 --default-launch-type FARGATE --config-name $2 --region $4
        echo

        # Allocate and launch the ECS cluster
        # PARAMS
        # - cluster-config: name of the config we generated earleir
        # - ecs-profile: name of the profile you want to use to run this command
        echo "Cluster resource allocation"
        ecs-cli up --cluster-config $2 --ecs-profile $3 2>&1 | tee cluster_details.txt
        echo
        # saving the VPC ID to a var

        VPC_ID=$(cat cluster_details.txt |grep -o 'vpc.*')


        # Creating a new security group. Finding the details of the security group ID
        echo "creating security rule to allow port 5000"
        aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC_ID --region $4 > security_details.json
        echo
        # Get the JSON parser
        sudo apt install jq

        # Parse the JSON for the group ID
        security_group_id=$(cat security_details.json | jq '.SecurityGroups[].GroupId' -r)

        # Allow our container to communicate through port 5000
        aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 5000 --cidr 0.0.0.0/0 --region $4

        # Run the python script to change the ecs-params.yml file
        python3 security_script.py
        
        # Upload the compose file
        echo "Docker image installation"
        ecs-cli compose --project-name $1 service up --create-log-groups --cluster-config $2 --ecs-profile $3
        echo
        # View the container ID
        echo "Container Detail/Cluster detail"
        ecs-cli compose --project-name $1 service ps --cluster-config $2 --ecs-profile $3
        echo
        exit 1
    else
        echo "Enter the correct details"
        exit 1
    fi

