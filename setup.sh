#!/bin/bash

#description     :This script will create a IAM role that can deploy clusters and tasks
#author		       :vineetred
#date            :20200620
#version         :0.2  

echo "
█▀█ █▀█ █░░ █▀▀   █▀▄ █▀▀ █▀█ █░░ █▀█ █▄█
█▀▄ █▄█ █▄▄ ██▄   █▄▀ ██▄ █▀▀ █▄▄ █▄█ ░█░"
echo

if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` <REGION-CODE> <ECS-PROFILE-NAME>"
  echo "Accepted region format - eu-west-2"
  echo "Refer to https://docs.aws.amazon.com/general/latest/gr/rande.html for correct codes"
  echo "Prompt will ask you for ACCESS KEY credentials."
  echo
  exit 1
fi

if [ $# -le 1 ]
  then
    echo "No arguments supplied/Missing args"
    exit 1
fi

echo "You will not see your keys"
echo
echo -n "ACCESS_KEY_ID:"
read -s ACCESS_KEY_ID
echo
echo -n "SECRET_ACCESS_KEY:"
read -s SECRET_ACCESS_KEY 
echo
# Deleting the keys from the history
history -c

echo "Updating libraries"
sudo apt-get update

echo "Installing AWS CLI"
sudo apt install awscli

RED='\033[0;31m'
ORANGE='\033[0;33m'

aws --version || (echo -e "${RED}[FAILUIRE] AWS CLI failed to install" && exit 1)

echo -e "${ORANGE}Installing ECS CLI"

sudo curl -o /usr/local/bin/ecs-cli https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest

echo "$(curl -s https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest.md5) /usr/local/bin/ecs-cli" | md5sum -c -

sudo chmod +x /usr/local/bin/ecs-cli

ecs-cli -v && echo -e "${ORANGE}ECS CLI OK"


echo -e "${ORANGE} Setting up the AWS Profile"


aws configure set aws_access_key_id $ACCESS_KEY_ID
aws configure set aws_secret_access_key $SECRET_ACCESS_KEY
aws configure set default.region $1


echo -e "${ORANGE} Setting up the IAM Role"

wget https://bucket-409rez.s3.ap-south-1.amazonaws.com/uploads/task-execution-assume-role.json


# UNCOMMENT IN CASE TASK DOES NOT EXIST ALREADY
# CHANGE THE ROLE NAME IN ECS-PARAMS.YML IF CHANGED HERE!
aws iam --region $1 create-role --role-name ecsTaskExecutionRole --assume-role-policy-document file://task-execution-assume-role.json

aws iam --region $1 attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
rm task-execution-assume-role.json

echo -e "${ORANGE} Setting up ECS CLI profile"

ecs-cli configure profile --access-key $ACCESS_KEY_ID --secret-key $SECRET_ACCESS_KEY --profile-name $2

echo -e "${ORANGE} Created a IAM role that can now spawn ECS instances. Run ./cluster_start.sh for deployment"
