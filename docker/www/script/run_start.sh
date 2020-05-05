#!/usr/bin/env bash
# trusted_host_patterns
# sed -i "s/@DOMAIN@/$APACHE_SERVER_NAME/" $SETTINGS
# database settings
cd /var/www || return
# source env vars and Insert the database settings into settings.php.
source /.env && vendor/bin/drupal dba --password=$POSTGRES_PASSWORD --driver=pgsql --host=$POSTGRES_HOST --database=$POSTGRES_DB \
--username=$POSTGRES_USER --port=5432 --default -n
