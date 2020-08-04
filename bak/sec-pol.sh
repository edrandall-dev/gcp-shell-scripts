#!/bin/bash

#Source the global variables
. ./0-gcp-global-vars.sh

#Ensure we're working with the correct project
runprint \
    gcloud config set project $PROJECT_NAME
sleep 1

#Create Security Policy
runprint \
    gcloud compute security-policies create $PROJECT_NAME-lb-policy

#Attach policy to web-backend-service
runprint \
    gcloud compute backend-services update web-backend-service \
    --security-policy=$PROJECT_NAME-lb-policy \
    --global
    
#Only Allow traffic from Home
runprint \
    gcloud compute security-policies rules create 3 \
    --security-policy $PROJECT_NAME-lb-policy \
    --expression "!inIpRange(origin.ip, '82.22.123.140/32')" \
    --action "deny-404"

# runprint \
#     gcloud compute security-policies rules create 1 \
#     --security-policy $PROJECT_NAME-lb-policy \
#     --expression "!inIpRange(origin.ip, '82.22.123.140/32') && request.path.matches('/wp-admin/')" \
#     --action "deny-404"

# runprint \
#     gcloud compute security-policies rules create 9999 \
#     --security-policy=$PROJECT_NAME-lb-policy \
#     --description="Default rule, higher priority overrides it" \
#     --src-ip-ranges=\* \
#     --action=deny-403 
