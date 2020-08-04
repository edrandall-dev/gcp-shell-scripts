#!/bin/bash

#Source the global variables
. var/0-gcp-global-vars.sh

show "Commencing build: $DATETIME"
echo

#A - Create VPC
echo
showrun \
    /bin/bash scripts/1-network-setup.sh 

#B - Create database and MIGs
echo
showrun \
    /bin/bash scripts/2-database-setup.sh 

#C - Create MIG
echo 
showrun \
    /bin/bash scripts/3-compute-setup.sh 

#D - Create Load Balancer
echo 
showrun \
    /bin/bash scripts/4-loadbalancer-setup.sh 

echo
echo "List of provisioned DB instances: "
gcloud beta sql instances list
echo
echo -ne "The Load Balancer's external IP address is: "
gcloud compute addresses describe lb-ipv4-1 --format="get(address)" --global
echo
echo "The following records are set in public DNS:"
host XXXXXX.uk | grep has
host www.XXXXXX.uk | grep has