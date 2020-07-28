#!/bin/bash

HOME_IP="$(host thelinuxnetwork.ddns.net | awk {'print $NF'})/32"

PROJECT_NAME="coen-ed-randall"
VPC="ed-wrdprs-vpc"

US_SUBNET_NAME="us-wrdprs-subnet"
US_SUBNET_RANGE="10.10.10.0/24"

EU_SUBNET_NAME="eu-wrdprs-subnet"
EU_SUBNET_RANGE="10.10.11.0/24"

SSH_FW_RULE_NAME="wrdprs-allow-ssh"
LB_FW_RULE_NAME="wrdprs-allow-health-check-and-proxy"

#Ensure gcloud is installed 
if ! command -v gcloud &> /dev/null
then
    echo "Error: gcloud could not be found, check '\$PATH'"
    exit 1
fi

run_and_show() 
{ 
    echo -ne "\nDoing -->  "
    echo -ne "\033[7m$@\033[0m"
    echo -e "  <--"
    "$@" 
    echo -e "\n"
}

clear