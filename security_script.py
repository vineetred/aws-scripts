#!/usr/bin/env python
import yaml
import subprocess

a_yaml_file = open("ecs-params.yml")
parsed_yaml_file = yaml.load(a_yaml_file, Loader=yaml.FullLoader)

temp = subprocess.check_output("cat cluster_details.txt |grep -o 'subnet.*'", shell = True).decode("utf-8")

subnets = []
tryy = ""
for char in temp:
    if(char == '\n'):
        subnets.append(tryy)
        tryy = ""
        continue
    tryy +=char


temp2 = subprocess.check_output("cat security_details.json | jq '.SecurityGroups[].GroupId' -r", shell= True).decode("utf-8")
temp2 = temp2.replace("\n","")

parsed_yaml_file['run_params']['network_configuration']['awsvpc_configuration']['security_groups'] = [temp2]
parsed_yaml_file['run_params']['network_configuration']['awsvpc_configuration']['subnets'][0] = subnets[0]
parsed_yaml_file['run_params']['network_configuration']['awsvpc_configuration']['subnets'][1] = subnets[1]

with open('ecs-params.yml', 'w') as file:
    documents = yaml.dump(parsed_yaml_file, file, sort_keys=False)