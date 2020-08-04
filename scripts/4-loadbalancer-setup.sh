#!/bin/bash

#Source the global variables
. var/0-gcp-global-vars.sh

#Ensure we're working with the correct project
showrun \
    gcloud config set project $PROJECT_NAME
sleep 1

# #Define HTTP service for the US and map a port name to the relevant port
# showrun \
#     gcloud compute instance-groups unmanaged set-named-ports ig-www-us \
#     --named-ports http:80 \
#     --zone=$US_REGION-b

#Define HTTP service for the EU and map a port name to the relevant port
showrun \
    gcloud compute instance-groups unmanaged set-named-ports ig-www-eu \
    --named-ports http:80 \
    --zone=$EU_REGION-b

#Define an http health check
showrun \
    gcloud compute health-checks create http http-basic-check \
        --port 80 \
        --request-path=/server.html

#Create a backend service
showrun \
    gcloud compute backend-services create web-backend-service \
        --global-health-checks \
        --protocol HTTP \
        --health-checks http-basic-check \
        --global
    
# #Add the US instance group as a backend
# showrun \
#     gcloud compute backend-services add-backend web-backend-service \
#         --balancing-mode=UTILIZATION \
#         --max-utilization=0.8 \
#         --capacity-scaler=1 \
#         --instance-group=ig-www-us \
#         --instance-group-zone=$US_REGION-b \
#         --global

#Add the EU instance group as a backend
showrun \
    gcloud compute backend-services add-backend web-backend-service \
        --balancing-mode=UTILIZATION \
        --max-utilization=0.8 \
        --capacity-scaler=1 \
        --instance-group=ig-www-eu \
        --instance-group-zone=$EU_REGION-b \
        --global

#Create a simple https URL Map
showrun \
    gcloud compute url-maps create web-map-https \
        --default-service web-backend-service

#Create a target HTTPS proxy to route requests to the https URL map.
showrun \
    gcloud compute target-https-proxies create https-lb-proxy \
    --url-map web-map-https --ssl-certificates edrandall-ssl-cert,www-edrandall-ssl-cert

#Create a global forwarding rule to route incoming requests to the proxy
showrun \
    gcloud compute forwarding-rules create https-content-rule \
        --address=lb-ipv4-1\
        --global \
        --target-https-proxy=https-lb-proxy \
        --ports=443

cat << 'EOF' > tmp/web-map-http.yaml
kind: compute#urlMap
name: web-map-http
defaultUrlRedirect:
   redirectResponseCode: MOVED_PERMANENTLY_DEFAULT
   httpsRedirect: True
EOF

#Create the HTTP load balancer's URL map by importing the YAML file. The name for this URL map is web-map-http.
showrun \
    gcloud compute url-maps import web-map-http \
        --source tmp/web-map-http.yaml \
        --global

#Remove the yaml file after creation
showrun \
    rm -f tmp/web-map-http.yaml

#Inserting a 20 second sleep, to ensure that web-map-http is ready
showrun \
    sleep 20

#Create a new target HTTP proxy, using web-map-http as the URL map.
showrun \
    gcloud compute target-http-proxies create http-lb-proxy \
        --url-map=web-map-http \
        --global

#Create a global forwarding rule to route incoming requests to the proxy.
showrun \
    gcloud compute forwarding-rules create http-content-rule \
        --address=lb-ipv4-1\
        --global \
        --target-http-proxy=http-lb-proxy \
        --ports=80

#Create Security Policy
showrun \
    gcloud compute security-policies create $PROJECT_NAME-lb-policy

#Attach policy to web-backend-service
showrun \
    gcloud compute backend-services update web-backend-service \
    --security-policy=$PROJECT_NAME-lb-policy \
    --global
    
#Only Allow traffic from Home
showrun \
    gcloud compute security-policies rules create 3 \
    --security-policy $PROJECT_NAME-lb-policy \
    --expression "!inIpRange(origin.ip, 'XX.XX.XX.XX/32')" \
    --action "deny-404"

# showrun \
#     gcloud compute security-policies rules create 1 \
#     --security-policy $PROJECT_NAME-lb-policy \
#     --expression "!inIpRange(origin.ip, 'XX.XX.XX.XX/32') && request.path.matches('/wp-admin/')" \
#     --action "deny-404"

# showrun \
#     gcloud compute security-policies rules create 9999 \
#     --security-policy=$PROJECT_NAME-lb-policy \
#     --description="Default rule, higher priority overrides it" \
#     --src-ip-ranges=\* \
#     --action=deny-403 