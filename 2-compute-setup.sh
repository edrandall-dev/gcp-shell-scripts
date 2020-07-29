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

# #Create the US instance template
# run_and_show \
#     gcloud compute instance-templates create www-us-template \
#         --region=$US_REGION \
#         --network=$VPC \
#         --subnet=$US_SUBNET_NAME \
#         --tags=$TCP_FW_RULE_HOME,$LB_FW_RULE_NAME \
#         --image-family=debian-9 \
#         --image-project=debian-cloud \
#         --metadata=startup-script='#! /bin/bash
#             apt-get update
#             apt-get install apache2 libapache2-mod-php7.0 mysql-client php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip php-mysql -y
#             a2ensite default-ssl
#             a2enmod ssl
#             a2dissite 000-default.conf
#             gsutil cp gs://edrandall-dev/wordpress/wordpress.conf /etc/apache2/sites-available/
#             rm -f /var/www/html/index.html
#             wget https://en-gb.wordpress.org/latest-en_GB.tar.gz
#             tar zxf latest-en_GB.tar.gz
#             mv wordpress/ /var/www/
#             chown -R www-data:www-data /var/www/wordpress
#             rm -f /var/www/wordpress/wp-config-sample.php
#             gsutil cp gs://edrandall-dev/wordpress/wp-config.php /var/www/wordpress/
#             find /var/www/wordpress/ -type d -exec chmod 750 {} \;
#             find /var/www/wordpress/ -type f -exec chmod 640 {} \;
#             vm_hostname="$(curl -H "Metadata-Flavor:Google" \
#             http://169.254.169.254/computeMetadata/v1/instance/name)"
#             echo "Page served from: $vm_hostname" | \
#             tee /var/www/wordpress/server.html
#             systemctl restart apache2'
# sleep 1

# #Create managed instance group for template 
# run_and_show \
#     gcloud compute instance-groups managed create ig-www-us \
#         --template=www-us-template --size=1 --zone=$US_REGION-b

#Create the EU instance template
run_and_show \
    gcloud compute instance-templates create www-eu-template \
        --region=$EU_REGION \
        --network=$VPC \
        --subnet=$EU_SUBNET_NAME \
        --tags=$TCP_FW_RULE_HOME,$LB_FW_RULE_NAME \
        --image-family=debian-9 \
        --image-project=debian-cloud \
        --metadata=startup-script='#! /bin/bash
            apt-get install apache2 apache2-utils libapache2-mod-php php php-curl php-gd php-intl php-mbstring php-mysql php-soap php-xml php-xmlrpc php-zip -y
            a2dissite 000-default.conf
            a2enmod vhost_alias
            a2enmod headers
            gsutil cp gs://edrandall-dev/wordpress/wordpress.conf /etc/apache2/sites-available/
            a2ensite wordpress
            rm -rf /var/www/html/
            wget https://en-gb.wordpress.org/latest-en_GB.tar.gz
            tar zxf latest-en_GB.tar.gz
            mkdir /var/www/wordpress
            mv wordpress/* /var/www/wordpress/
            rmdir wordpress
            chown -R www-data:www-data /var/www/wordpress
            chmod -R 775 /var/www/wordpress/
            rm -f /var/www/wordpress/wp-config-sample.php
            gsutil cp gs://edrandall-dev/wordpress/wp-config.php /var/www/wordpress/
            vm_hostname="$(curl -H "Metadata-Flavor:Google" \
            http://169.254.169.254/computeMetadata/v1/instance/name)"
            echo "Page served from: $vm_hostname" | \
            tee /var/www/wordpress/server.html
            systemctl restart apache2'
sleep 1

#Create managed instance group for template 
run_and_show \
    gcloud compute instance-groups managed create ig-www-eu \
        --template=www-eu-template --size=1 --zone=$EU_REGION-b
