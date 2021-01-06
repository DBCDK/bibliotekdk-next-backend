#!/usr/bin/env bash
# trusted_host_patterns
# sed -i "s/@DOMAIN@/$APACHE_SERVER_NAME/" $SETTINGS

# get files from prod if in staging namespace
cd /tmp || return
if [ "$NAMESPACE_NAME" == 'frontend-staging' ]; then
  # Fetch the files folder from prod.
  tar -xf files.tar.gz
  rm -rf /var/www/web/sites/default/files/*
  cp -Rf files /var/www/web/sites/default
  chown -Rf www-data:www-data /var/www/web/sites/default/files
  rm -rf files files.tar.gz
fi
# database settings
cd /var/www || return
ls -la
# Insert the database settings into settings.php.
vendor/bin/drupal dba --password=$POSTGRES_PASSWORD --driver=pgsql --host=$POSTGRES_HOST \
 --database=$POSTGRES_DB --username=$POSTGRES_USER --port=5432 --default -n
