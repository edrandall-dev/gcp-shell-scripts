#!/bin/bash

#Source the global variables
. ./0-gcp-global-vars.sh

#Ensure we're working with the correct project
runprint\
    gcloud config set project $PROJECT_NAME
sleep 1

#Create the database instance
runprint\
    gcloud beta sql instances create $DB_INSTANCE \
        --tier=db-f1-micro \
        --region=europe-west2 \
        --database-version MYSQL_5_7 \
        --network $VPC \
        --no-assign-ip \
        --storage-type SSD \
        --availability-type ZONAL \

#Create root user
runprint\
    gcloud sql users set-password root --host=% --instance $DB_INSTANCE --password $DB_ROOT_PASSWORD

#Create the Database
runprint\
    gcloud beta sql databases create $DB_NAME --instance=$DB_INSTANCE 

#Check if the wp-config file is actually in the current directory
[ -f ./wp-config.php ] || { echo "Can't find wp-config.php file in the CWD. Manual intervention required to update the target DB IP"; exit 1; }

#Change the IP address from OLD_IP to NEW_IP in the wp-config.php file in the current directory
OLD_IP=$(grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' wp-config.php)
NEW_IP=$(gcloud beta sql instances describe $DB_INSTANCE --format="get(ipAddresses[0].ipAddress)")
sed -ie "s/$OLD_IP/$NEW_IP/" wp-config.php

echo -e "The OLD Database IP (in the local copy of wp-config.php) was:\t$OLD_IP"
echo -e "The NEW IP (in the local copy of wp-config.php) is:\t$NEW_IP"

#Maybe do something similar for the DB root password??

#Copy the modified file into the bucket for the instances to pull down as part of their startup script
gsutil cp ./wp-config.php gs://edrandall-dev/wordpress/ 
