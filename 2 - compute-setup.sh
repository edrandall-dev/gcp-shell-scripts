#!/bin/bash

#Source the global variables
. ./gcp-global-vars.sh

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
        --tags=$SSH_FW_RULE_NAME \
        --tags=$LB_FW_RULE_NAME \
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
        --tags=$SSH_FW_RULE_NAME \
        --tags=$LB_FW_RULE_NAME \
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

#
# Load Balancer Section
#

#Define HTTP service for the US and map a port name to the relevant port
run_and_show \
    gcloud compute instance-groups unmanaged set-named-ports ig-www-us \
    --named-ports http:80 \
    --zone=$US_REGION-b

#Define HTTP service for the EU and map a port name to the relevant port
run_and_show \
    gcloud compute instance-groups unmanaged set-named-ports ig-www-eu \
    --named-ports http:80 \
    --zone=$EU_REGION-b

#Define a simple http health check
run_and_show \
    gcloud compute health-checks create http http-basic-check \
        --port 80

#Create a simple backend service
run_and_show \
    gcloud compute backend-services create web-backend-service \
        --global-health-checks \
        --protocol HTTP \
        --health-checks http-basic-check \
        --global
    
#Add the EU instance group as a backend
run_and_show \
    gcloud compute backend-services add-backend web-backend-service \
        --balancing-mode=UTILIZATION \
        --max-utilization=0.8 \
        --capacity-scaler=1 \
        --instance-group=ig-www-us \
        --instance-group-zone=$US_REGION-b \
        --global

#Add the EU instance group as a backend
run_and_show \
    gcloud compute backend-services add-backend web-backend-service \
        --balancing-mode=UTILIZATION \
        --max-utilization=0.8 \
        --capacity-scaler=1 \
        --instance-group=ig-www-eu \
        --instance-group-zone=$EU_REGION-b \
        --global

#Create a simple URL Map
run_and_show \
    gcloud compute url-maps create web-map \
        --default-service web-backend-service

#Create a target HTTPS proxy to route requests to the URL map.
run_and_show \
    gcloud compute target-https-proxies create https-lb-proxy \
    --url-map web-map --ssl-certificates www-ssl-cert

#Create a global forwarding rule to route incoming requests to the proxy
run_and_show \
    gcloud compute forwarding-rules create https-content-rule \
        --address=lb-ipv4-1\
        --global \
        --target-https-proxy=https-lb-proxy \
        --ports=443

#Print the IP address from the load balancer
run_and_show \
    gcloud compute addresses describe lb-ipv4-1 \
    --format="get(address)" \
    --global