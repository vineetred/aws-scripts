#!/bin/bash

echo "
█▀▀ █░░ █░█ █▀ ▀█▀ █▀▀ █▀█   █▀▄ █▀▀ █▀ ▀█▀ █▀█ █▀█ █▄█
█▄▄ █▄▄ █▄█ ▄█ ░█░ ██▄ █▀▄   █▄▀ ██▄ ▄█ ░█░ █▀▄ █▄█ ░█░" 
echo

if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` <PROJECT-NAME> <CLUSTER-CONFIG> <ECS-PROFILE> "
  echo "Do go through the README.md"
  exit 1
fi

if [ $# -le 2 ]
  then
    echo "No arguments supplied"
    exit 1
fi

echo PROJECT NAME - $1
echo CLUSTER CONFIG - $2
echo ECS PROFILE - $3
echo 
read -p "Are these details correct? [Yy]"
echo 

if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo "<--- Deleting cluster $2 from project $1 --->"
		ecs-cli compose --project-name $1 service down --cluster-config $2 --ecs-profile $3

		ecs-cli down --force --cluster-config $2 --ecs-profile $3
    echo
    echo "<--- DELETED --->"
    exit 1

	else
		echo "Restart the script with new args"
    exit 1
fi
