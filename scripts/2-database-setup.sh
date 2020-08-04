#!/bin/bash

#Source the global variables
. var/0-gcp-global-vars.sh

#Ensure we're working with the correct project
showrun \
    gcloud config set project $PROJECT_NAME
sleep 1

#Create the database instance
showrun \
    gcloud beta sql instances create $DB_INSTANCE \
        --tier=db-f1-micro \
        --region=europe-west2 \
        --database-version MYSQL_5_7 \
        --network $VPC \
        --no-assign-ip \
        --storage-type SSD \
        --availability-type ZONAL \

[ $? = 0 ] || { echo -e "\n*** Exiting due to error, does the DB instance name need to be incremented?. ***\n" ; exit 1 ;} ;

#Create root user
showrun \
    gcloud sql users set-password root --host=% --instance $DB_INSTANCE --password $DB_ROOT_PASSWORD

#Create the Database
showrun \
    gcloud beta sql databases create $DB_NAME --instance=$DB_INSTANCE 

#Output the new database ip address to the varitable DB_IP, for later substitution
DB_IP=$(gcloud beta sql instances describe $DB_INSTANCE --format="get(ipAddresses[0].ipAddress)")

#Create a wp-config.php file, ready for the IP address and DB Root Password to be added with 'sed -e' in the next step
cat << 'EOF' > tmp/wp-config.php
<?php

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wrdprs' );

/** MySQL database username */
define( 'DB_USER', 'root' );

/** MySQL database password */
define( 'DB_PASSWORD', 'DB_ROOT_PASSWORD_GOES_HERE' );

/** MySQL hostname */
define( 'DB_HOST', 'DB_IP_ADDRESS_GOES_HERE' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

define( 'AUTH_KEY',         '6x4 Nk~X#%S, o ,TM67-*5xxr=+E+p (0HPq=LUf;DiMRvoR$+Z}ULGR@U1joA{' );
define( 'SECURE_AUTH_KEY',  ' n+Bm(Zir&}~GlWU!Xz&gQeJh;iKO94+)5~4c1T/$&{?8{fQvN5V+rB(B4.ZH.m)' );
define( 'LOGGED_IN_KEY',    ':P;wP4{`Wt-4NV;Pr<%*amVgK-90 ZJ=X*fuMjPdieV%}JWg* 1#>c<|1ANIp_Np' );
define( 'NONCE_KEY',        'pjZ8E[&:*Mc%o,9`M(5Zb[KQ]SatvIs`&m)*A<TS~qeOAy~Qv6PFmo]Yf.~bm9[l' );
define( 'AUTH_SALT',        '%oIn4>]X`-w>d3S{uo5c0R||_]*v5(cT=%}!S4}@0[Uiq-&l:b}YGV]@oe6f0TTV' );
define( 'SECURE_AUTH_SALT', '1Qo4ayN&D,99Dw@/^cF@/9hJoH6jwc5j86AR(,L0zphm8;HS!]h,nj++Y:^)sP].' );
define( 'LOGGED_IN_SALT',   'hZ#6noF#4I?{&8X4I(e[erj;7b,k6MAdN Y)d2Et>H} 3x)&W;!REdgu.+ZawWU:' );
define( 'NONCE_SALT',       'J6)n3;g`#BizY@P>q;>NBr]zL`iw8@[g|:c6%[SZ|~y xk6#Vr*%0|kHVx$2Hnvj' );

$table_prefix = 'wp_';

define( 'WP_DEBUG', false );

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
EOF

#Replace the IP and the DB_ROOT_PW in the file we've just created
sed -ie "s/DB_ROOT_PASSWORD_GOES_HERE/$DB_ROOT_PASSWORD/" tmp/wp-config.php
sed -ie "s/DB_IP_ADDRESS_GOES_HERE/$DB_IP/" tmp/wp-config.php

#Copy the wp-config.php file into the bucket for the instances to pull down as part of their startup script
gsutil cp tmp/wp-config.php gs://edrandall-dev/wordpress/

#Remove the local copy of ./wp-config.php
rm -f tmp/wp-config.php