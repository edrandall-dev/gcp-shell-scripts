#!/bin/bash

./1-network-setup.sh
./2-database-setup.sh
./3-compute-setup.sh
./4-loadbalancer-setup.sh

echo "List of provisioned DB instances: "
gcloud beta sql instances list



