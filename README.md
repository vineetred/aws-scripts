# GUIDE
## These scripts allow one to deploy, scale and destroy Docker containers on AWS ECS Fargate.

* setup.sh - TO CREATE AN IAM ROLE AND ECS PROFILE THAT CAN SPAWM CLUSTERS AND CONTAINERS
* cluster_start.sh - ONLY WHEN CLUSTER HAS NOT BEEN SPAWNED YET. GENERATES A NEW CLUSTER WITH THE GIVEN PARAMS
* container_scale_start.sh - ONLY AFTER A CLUSTER HAS BEEN SPAWNED. SCALES THE CONTAINERS.
* desotroy_cluster.sh- DESTROY ALL RESOURCES ALLOCATED.

Note - Give the scripts neccesary permission using ```chmod +x <SCRIPT PATH>```
