#!/bin/bash

#Change the following variable to a source IP as required
HOME_IP="$(host XXXXXX.ddns.net | awk {'print $NF'})/32"

PROJECT_NAME="XXXX-XX-XXXXXX"
VPC="$PROJECT_NAME-vpc"

DATETIME=$(date +%F-%H%M)

US_REGION="us-east1"
US_SUBNET_NAME="$PROJECT_NAME-us-subnet"
US_SUBNET_RANGE="10.10.10.0/24"

EU_REGION="europe-west2"
EU_SUBNET_NAME="$PROJECT_NAME-eu-subnet"
EU_SUBNET_RANGE="10.10.11.0/24"

TCP_FW_RULE_HOME="all-tcp-from-home"
LB_FW_RULE_NAME="wrdprs-allow-health-check-and-proxy"

DB_INSTANCE="$PROJECT_NAME-$DATETIME"
DB_NAME="wrdprs"
DB_ROOT_PASSWORD="passwordgoesherebutthisisntit"

#Ensure gcloud is installed 
if ! command -v gcloud &> /dev/null
then
    echo "Error: gcloud could not be found, check '\$PATH'"
    exit 1
fi

showrun() 
{ 
    echo -ne "\nDoing -->  "
    echo -ne "\033[7m$@\033[0m"
    echo -e "  <--\n"
    "$@" 
    echo "________________________________________________________________________________________________________"
}

show()
{ 
    echo -ne "**** "
    echo -ne "\033[7m$@\033[0m"
    echo -e " ****"
}

log()
{ 
    echo -ne "**** "
    echo -ne "\033[7m$@\033[0m"
    echo -e " ****"
}
