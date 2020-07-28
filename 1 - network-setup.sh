#!/bin/bash

#Source the global variables
. ./gcp-global-vars.sh

#Ensure we're working with the correct project
run_and_show \
    gcloud config set project $PROJECT_NAME
sleep 1

#Create the VPC
run_and_show \
    gcloud compute networks create $VPC --subnet-mode=custom
sleep 1

#Create the US SUBNET
run_and_show \
    gcloud compute networks subnets create $US_SUBNET_NAME \
        --network=$VPC \
        --range=$US_SUBNET_RANGE \
        --region=$US_REGION
sleep 1

#Create the EU Subnet
run_and_show \
    gcloud compute networks subnets create $EU_SUBNET_NAME \
        --network=$VPC \
        --range=$EU_SUBNET_RANGE \
        --region=$EU_REGION
sleep 1

#Create SSH ingress FW Rule (from $HOME_IP)
run_and_show \
    gcloud compute firewall-rules create $SSH_FW_RULE_NAME \
        --network=$VPC \
        --action=allow \
        --direction=ingress \
        --target-tags=$SSH_FW_RULE_NAME \
        --source-ranges=$HOME_IP \
        --rules=tcp:22
sleep 1

#Create FW rule to allow google lb health checks
run_and_show \
    gcloud compute firewall-rules create $LB_FW_RULE_NAME \
        --network=$VPC \
        --action=allow \
        --direction=ingress \
        --target-tags=$LB_FW_RULE_NAME \
        --source-ranges=130.211.0.0/22,35.191.0.0/16 \
        --rules=tcp:80,tcp:443
sleep 1

# #Create a (google managed) SSL certificate
# run_and_show \
#     gcloud beta compute ssl-certificates create www-ssl-cert \
#     --domains www.edrandall.dev
# sleep 1

# #Reserve a Public IP address for the load balancer to use
# run_and_show \
#     gcloud compute addresses create lb-ipv4-1 \
#         --ip-version=IPV4 \
#         --global
