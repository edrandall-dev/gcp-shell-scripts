#!/bin/bash

#Source the global variables
. ./0-gcp-global-vars.sh

#Ensure we're working with the correct project
run_and_show \
    gcloud config set project $PROJECT_NAME
sleep 1

#
# Compute Section
#

#Create the US instance template
run_and_show \
    gcloud compute instance-templates create www-us-template \
        --region=$US_REGION \
        --network=$VPC \
        --subnet=$US_SUBNET_NAME \
        --tags=$SSH_FW_RULE_NAME,$LB_FW_RULE_NAME \
        --image-family=debian-9 \
        --image-project=debian-cloud \
        --metadata=startup-script='#! /bin/bash
            apt-get update
            apt-get install apache2 -y
            a2ensite default-ssl
            a2enmod ssl
            wget https://en-gb.wordpress.org/latest-en_GB.tar.gz
            tar zxf latest-en_GB.tar.gz
            mv wordpress/* /var/www/html
            vm_hostname="$(curl -H "Metadata-Flavor:Google" \
            http://169.254.169.254/computeMetadata/v1/instance/name)"
            echo "Page served from: $vm_hostname" | \
            tee /var/www/html/server.html
            systemctl restart apache2'
sleep 1

#Create managed instance group for template 
run_and_show \
    gcloud compute instance-groups managed create ig-www-us \
        --template=www-us-template --size=1 --zone=$US_REGION-b

#Create the EU instance template
run_and_show \
    gcloud compute instance-templates create www-eu-template \
        --region=$EU_REGION \
        --network=$VPC \
        --subnet=$EU_SUBNET_NAME \
        --tags=$SSH_FW_RULE_NAME,$LB_FW_RULE_NAME \
        --image-family=debian-9 \
        --image-project=debian-cloud \
        --metadata=startup-script='#! /bin/bash
            apt-get update
            apt-get install apache2 -y
            a2ensite default-ssl
            a2enmod ssl
            wget https://en-gb.wordpress.org/latest-en_GB.tar.gz
            tar zxf latest-en_GB.tar.gz
            mv wordpress/* /var/www/html
            vm_hostname="$(curl -H "Metadata-Flavor:Google" \
            http://169.254.169.254/computeMetadata/v1/instance/name)"
            echo "Page served from: $vm_hostname" | \
            tee /var/www/html/server.html
            systemctl restart apache2'
sleep 1

#Create managed instance group for template 
run_and_show \
    gcloud compute instance-groups managed create ig-www-eu \
        --template=www-eu-template --size=1 --zone=$EU_REGION-b
        