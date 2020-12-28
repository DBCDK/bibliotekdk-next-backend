#!/usr/bin/env bash
SETTINGS=/var/www/web/sites/default/settings.php
# memcache settings
MEMCACHE="$settings['memcache']['servers'] = ['bibdk-backend-memcached-master:11211' => 'default']; \
$settings['memcache']['bins'] = ['default' => 'default']; \
$settings['memcache']['key_prefix'] = ''; \
$settings['cache']['default'] = 'cache.backend.memcache'; \
$settings['cache']['bins']['render'] = 'cache.backend.memcache';"

echo $MEMCACHE
# sed -i "s/@DOMAIN@/$APACHE_SERVER_NAME/" $SETTINGS
$MEMCACHE >> $SETTINGS
