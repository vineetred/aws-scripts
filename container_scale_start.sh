#!/bin/bash
echo "
█▀▀ █░░ █░█ █▀ ▀█▀ █▀▀ █▀█   █▀ █▀▀ ▄▀█ █░░ █▀▀ █▀█
█▄▄ █▄▄ █▄█ ▄█ ░█░ ██▄ █▀▄   ▄█ █▄▄ █▀█ █▄▄ ██▄ █▀▄"
echo

if [ "$1" == "-h" ]; then
  echo "Usage: `basename $0` <PROJECT-NAME> <CLUSTER-CONFIG> <ECS-PROFILE> <NUMBER-OF-CONTAINERS>"
  echo
  echo "[INFO] The number of containers must be greater than 0"
  echo
  echo "If you want to just view the IP"
  echo "Usage: `basename $0` <PROJECT-NAME> <CLUSTER-CONFIG> <ECS-PROFILE> -v"
  echo 
  echo "Go through the README.md if you already have not"
  exit 1
fi

if [[ "$4" == "-v" ]]
  then
    echo "Viewing the IPV4 addresses of our deployed containers"
    ecs-cli compose --project-name $1 service ps --cluster-config $2 --ecs-profile $3
    exit 1
fi

if [[ $# -le 3 ]]
  then
    echo "No arguments supplied/Missing args"
    exit 1
fi

if [[ $4 -le 0 ]]
  then
    echo "ERROR Container number has to be greater than 0"
    exit 1
fi


echo PROJECT NAME - $1
echo CLUSTER CONFIG - $2
echo ECS PROFILE - $3
echo NUMBER OF CONTAINERS - $4
echo 
read -p "Are these details correct? [Yy]"
echo 

if [[ $REPLY =~ ^[Yy]$ ]]
	then
		echo "Scaling project $1 using config $2"
        for (( i=2; i <= $4+1; ++i ))
            do
                echo "Starting container $i"
                ecs-cli compose --project-name $1 service scale $i --cluster-config $2 --ecs-profile $3
                echo
            done
        ecs-cli compose --project-name $1 service ps --cluster-config $2 --ecs-profile $3
        exit 1

	else
		echo "Restart the script with new args"
        exit 1
fi
