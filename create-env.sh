#!/bin/bash

#A - Create VPC
scripts/1-network-setup.sh

#B - Create database and MIGs
scripts/2-database-setup.sh &
scripts/3-compute-setup.sh

#C - Create Load Balancer
scripts/4-loadbalancer-setup.sh

echo

echo "List of provisioned DB instances: "
gcloud beta sql instances list

echo

echo -ne "The Load Balancer's external IP address is: "
gcloud compute addresses describe lb-ipv4-1 --format="get(address)" --global

echo
echo "The following records are set in public DNS:"
host edrandall.uk | grep has
host www.edrandall.uk | grep has