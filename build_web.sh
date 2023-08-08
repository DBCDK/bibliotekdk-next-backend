#!/bin/bash

# get code from latest develop image
docker run -d  --name backend_temp docker-frontend.artifacts.dbccloud.dk/bibdk-backend-www-develop

docker exec -it backend_temp /bin/bash -c "cd /var/www/web/sites/default && ls -la"
# copy vcs files
docker cp backend_temp:/var/www .
# delete temp container
docker kill backend_temp
docker rm backend_temp

docker-compose up -d
# wait for database
./check_and_wait.sh "localhost:7070"
# site is running - do some file permission and drush
docker exec -it bibliotekdk-next-backend_drupal8_1 /bin/bash -c "chown -R www-data:www-data /var/www/web  && cd /var/www/vendor/bin && php drush cr"
