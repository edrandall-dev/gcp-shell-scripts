<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wrdprs' );

/** MySQL database username */
define( 'DB_USER', 'root' );

/** MySQL database password */
define( 'DB_PASSWORD', 'passwordgoesherebutthisisntit' );

/** MySQL hostname */
define( 'DB_HOST', '172.30.0.5' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8mb4' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',         '6x4 Nk~X#%S, o ,TM67-*5xxr=+E+p (0HPq=LUf;DiMRvoR$+Z}ULGR@U1joA{' );
define( 'SECURE_AUTH_KEY',  ' n+Bm(Zir&}~GlWU!Xz&gQeJh;iKO94+)5~4c1T/$&{?8{fQvN5V+rB(B4.ZH.m)' );
define( 'LOGGED_IN_KEY',    ':P;wP4{`Wt-4NV;Pr<%*amVgK-90 ZJ=X*fuMjPdieV%}JWg* 1#>c<|1ANIp_Np' );
define( 'NONCE_KEY',        'pjZ8E[&:*Mc%o,9`M(5Zb[KQ]SatvIs`&m)*A<TS~qeOAy~Qv6PFmo]Yf.~bm9[l' );
define( 'AUTH_SALT',        '%oIn4>]X`-w>d3S{uo5c0R||_]*v5(cT=%}!S4}@0[Uiq-&l:b}YGV]@oe6f0TTV' );
define( 'SECURE_AUTH_SALT', '1Qo4ayN&D,99Dw@/^cF@/9hJoH6jwc5j86AR(,L0zphm8;HS!]h,nj++Y:^)sP].' );
define( 'LOGGED_IN_SALT',   'hZ#6noF#4I?{&8X4I(e[erj;7b,k6MAdN Y)d2Et>H} 3x)&W;!REdgu.+ZawWU:' );
define( 'NONCE_SALT',       'J6)n3;g`#BizY@P>q;>NBr]zL`iw8@[g|:c6%[SZ|~y xk6#Vr*%0|kHVx$2Hnvj' );

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

