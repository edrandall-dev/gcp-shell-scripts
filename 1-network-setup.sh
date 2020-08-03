#!/bin/bash

#Source the global variables
. ./0-gcp-global-vars.sh

#Ensure we're working with the correct project
runprint \
    gcloud config set project $PROJECT_NAME
sleep 1

#Create the VPC
runprint \
    gcloud compute networks create $VPC --subnet-mode=custom
sleep 1

# #Create the US SUBNET
# runprint \
#     gcloud compute networks subnets create $US_SUBNET_NAME \
#         --network=$VPC \
#         --range=$US_SUBNET_RANGE \
#         --region=$US_REGION
# sleep 1

#Create the EU Subnet
runprint \
    gcloud compute networks subnets create $EU_SUBNET_NAME \
        --network=$VPC \
        --range=$EU_SUBNET_RANGE \
        --region=$EU_REGION
sleep 1

#Create FW rule to allow all trafic to hosts with this tag from home
runprint \
    gcloud compute firewall-rules create $TCP_FW_RULE_HOME \
        --direction=INGRESS \
        --priority=1000 \
        --network=$VPC \
        --action=ALLOW \
        --rules=tcp \
        --source-ranges=$HOME_IP \
        --target-tags=$TCP_FW_RULE_HOME

#Create FW rule to allow google lb health checks
runprint \
    gcloud compute firewall-rules create $LB_FW_RULE_NAME \
        --network=$VPC \
        --action=allow \
        --direction=ingress \
        --target-tags=$LB_FW_RULE_NAME \
        --source-ranges=130.211.0.0/22,35.191.0.0/16 \
        --rules=tcp:80,tcp:443
sleep 1

#Configuring private services access for Cloud SQL: 1 - Allocating an IP address range
runprint \
    gcloud compute addresses create google-managed-services-$VPC \
        --global \
        --purpose=VPC_PEERING \
        --prefix-length=16 \
        --network=$VPC \
        --project=$PROJECT_NAME

#Configuring private services access for Cloud SQL: 2 - Create the Private Connection
runprint \
    gcloud services vpc-peerings connect \
        --service=servicenetworking.googleapis.com \
        --ranges=google-managed-services-$VPC \
        --network=$VPC \
        --project=$PROJECT_NAME

#Create a (google managed) SSL certificate
runprint \
    gcloud beta compute ssl-certificates create www-edrandall-ssl-cert \
    --domains www.edrandall.uk


#Create a (google managed) SSL certificate
runprint \
    gcloud beta compute ssl-certificates create edrandall-ssl-cert \
    --domains edrandall.uk



#Reserve a Public IP address for the load balancer to use
runprint \
    gcloud compute addresses create lb-ipv4-1 \
        --ip-version=IPV4 \
        --global

#Finally, print the IP address from the load balancer
echo -ne "The Load Balancer's external IP address is: "
gcloud compute addresses describe lb-ipv4-1 --format="get(address)" --global