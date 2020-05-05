#!/usr/bin/env bash
# environment
source .env
# trusted_host_patterns
sed -i "s/@DOMAIN@/$APACHE_SERVER_NAME/" $SETTINGS
# database settings
cd /var/www || return
# Insert the database settings into settings.php.
vendor/bin/drupal dba --password=$POSTGRES_PASSWORD --driver=pgsql --host=$POSTGRES_HOST --database=$POSTGRES_DB \
--username=$POSTGRES_USER --port=5432 --default -n
