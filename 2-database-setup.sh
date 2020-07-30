#!/bin/bash

#Source the global variables
. ./0-gcp-global-vars.sh

#Ensure we're working with the correct project
run_and_show \
    gcloud config set project $PROJECT_NAME
sleep 1

#These vars can go into global-vars later

DB_INSTANCE="wrdprs-instance5"
DB_NAME="wrdprs"
WORDPRESS_DB_USER="wp_user"

#Create the database instance
run_and_show \
    gcloud beta sql instances create $DB_INSTANCE \
        --tier=db-f1-micro \
        --region=europe-west2 \
        --database-version MYSQL_5_7 \
        --network $VPC \
        --no-assign-ip \
        --storage-type SSD \
        --availability-type ZONAL \

#Create root user
run_and_show \
    gcloud sql users set-password root --host=% --instance $DB_INSTANCE --password 8IibuJnPMeALjhfduJnPMeALjh124

#Create the Database
run_and_show \
    gcloud beta sql databases create $DB_NAME --instance=$DB_INSTANCE 

#Create the Wordpress DB User
run_and_show \
    gcloud sql users set-password $WORDPRESS_DB_USER--host=% --instance $DB_INSTANCE --password hfduJnPMeALPMeALj8IibuJnPM

#Print out the IP address of the database 
run_and_show \
    gcloud beta sql instances describe wrdprs-instance2 --format="get(ipAddresses[0].ipAddress)"
