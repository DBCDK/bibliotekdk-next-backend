#!/usr/bin/env bash
# trusted_host_patterns
# sed -i "s/@DOMAIN@/$APACHE_SERVER_NAME/" $SETTINGS
# database settings
echo $NAMESPACE_NAME
cd /tmp || return
if [ "$NAMESPACE_NAME" == 'frontend-staging' ]; then
  #We do not need to include the files.tar.gz file.
  rm -rf files.tar.gz
else
  # Fetch the files folder from prod.
  tar -xf files.tar.gz
  rm -rf /var/www/web/sites/default/files/*
  cp -Rf files /var/www/web/sites/default
  chown -Rf www-data:www-data /var/www/web/sites/default/files
  rm -rf files files.tar.gz
fi


cd /var/www || return
ls -la
# source env vars and Insert the database settings into settings.php.
source /.env && vendor/bin/drupal dba --password=$POSTGRES_PASSWORD --driver=pgsql --host=$POSTGRES_HOST \
 --database=$POSTGRES_DB --username=$POSTGRES_USER --port=5432 --default -n
