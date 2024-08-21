ARG BRANCH=develop
FROM docker-frontend.artifacts.dbccloud.dk/d9-php8-builder:latest as builder
ENV BRANCH=${BRANCH}
ENV DEBIAN_FRONTEND=noninteractive

USER root
WORKDIR /var/lib/jenkins
RUN apt-key adv --fetch-keys https://packages.sury.org/php/apt.gpg

USER root

RUN apt-get update && \
    apt-get -q -y install git ssh patch unzip && \
    apt-get autoremove -y

#ADD composer.lock ./www/
#ADD composer.json ./www/
#RUN chown -R jenkins:jenkins /var/lib/jenkins/www
ADD www www
RUN chown -R jenkins:jenkins /var/lib/jenkins
USER jenkins
WORKDIR /var/lib/jenkins/www
RUN ls -la /var/lib/
RUN ls -la

RUN composer update --no-dev --with-dependencies
# get secrets from private gitlab
RUN git clone gitlab@gitlab.dbc.dk:frontend/bibdk-backend-settings.git && cd bibdk-backend-settings && git checkout ${BRANCH}

FROM docker-dbc.artifacts.dbccloud.dk/dbc-apache-php8

#ENV NAMESPACE_NAME=frontend-features \
#    APACHE_ROOT=/var/www/web \
#    APACHE_RUN_DIR=/var/run/apache2 \
#    APACHE_SERVER_NAME=bibdk-backend-www-${BRANCH}.${NAMESPACE_NAME}.svc.cloud.dbc.dk \
#    MEMCACHED_SERVER=bibdk-backend-memcached-${BRANCH}.${NAMESPACE_NAME}.svc.cloud.dbc.dk \
#    POSTGRES_HOST=bibdk-backend-db-${BRANCH}.frontend-features.svc.cloud.dbc.dk
ENV DEBIAN_FRONTEND=noninteractive \
    NAMESPACE_NAME=frontend-features \
    APACHE_ROOT=/var/www/web \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_SERVER_NAME=bibdk-backend-www-${BRANCH}.${NAMESPACE_NAME}.svc.cloud.dbc.dk \
    MEMCACHED_SERVER=bibdk-backend-memcached-${BRANCH}.${NAMESPACE_NAME}.svc.cloud.dbc.dk \
    URL_PATH=''


USER root
RUN apt-get update && \
	apt-get -q -y install postgresql-client msmtp msmtp-mta s-nail unzip  && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get autoremove -y && \
	a2enmod rewrite headers cache_disk

WORKDIR /var/www
COPY --from=builder /var/lib/jenkins/www /var/www

#RUN rm -rf change_branch.sh .editorconfig .gitattributes html
RUN rm -rf html change_branch.sh .editorconfig .gitattributes core/update.php

#COPY --from=builder /var/lib/jenkins/www/bibdk-backend-settings/conf/fqdn.conf /etc/apache2/conf-available/
COPY --from=builder /var/lib/jenkins/www/bibdk-backend-settings/conf/000-default.conf /etc/apache2/sites-enabled/
COPY --from=builder /var/lib/jenkins/www/bibdk-backend-settings/conf/000-default.conf /etc/apache2/sites-available/
COPY --from=builder /var/lib/jenkins/www/bibdk-backend-settings/conf/settings.php /var/www/web/sites/default/
COPY --from=builder /var/lib/jenkins/www/bibdk-backend-settings/conf/settings.local.php /var/www/web/sites/default/
ADD --chown=www-data:www-data ["https://is.dbc.dk/view/frontend/job/bibliotekdk-next/job/Fetch%20bibdk-backend%20files/lastSuccessfulBuild/artifact/files.tar.gz", "/tmp/"]
ADD script/run_dev_start.sh /
ADD script/run_master_start.sh /
ADD script/config_memcache.sh /

RUN mkdir ${APACHE_ROOT}/sites/default/files
RUN mkdir ${APACHE_ROOT}/sites/default/files/config_bibdk
RUN chown -R www-data:www-data /var/www/web
RUN chmod -R 775 ${APACHE_ROOT}/sites/default/files
