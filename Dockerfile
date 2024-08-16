ARG BRANCH=develop

FROM docker-frontend.artifacts.dbccloud.dk/d9-php8-builder as builder

ARG BRANCH

ENV BRANCH=${BRANCH}

USER root
WORKDIR /var/lib/jenkins
RUN apt-key adv --fetch-keys https://packages.sury.org/php/apt.gpg

RUN apt-get update && \
    apt-get -q -y install php-intl php-soap git ssh unzip && \
    apt-get autoremove -y

#ADD composer.lock ./www/
#ADD composer.json ./www/
#RUN chown -R jenkins:jenkins /var/lib/jenkins/www
ADD www www
RUN chown -R jenkins:jenkins /var/lib/jenkins/www
USER jenkins
WORKDIR /var/lib/jenkins/www
RUN ls -la /var/lib/
RUN ls -la

RUN composer up
# get secrets from private gitlab
RUN git clone gitlab@gitlab.dbc.dk:frontend/bibdk-backend-settings.git && cd bibdk-backend-settings && git checkout master

FROM docker-dbc.artifacts.dbccloud.dk/dbc-apache-php8:latest

ENV NAMESPACE_NAME=frontend-features \
    APACHE_ROOT=/var/www/web \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_SERVER_NAME=bibdk-backend-www-${BRANCH}.${NAMESPACE_NAME}.svc.cloud.dbc.dk \
    MEMCACHED_SERVER=bibdk-backend-memcached-${BRANCH}.${NAMESPACE_NAME}.svc.cloud.dbc.dk \
    POSTGRES_HOST=bibdk-backend-db-${BRANCH}.frontend-features.svc.cloud.dbc.dk

RUN apt-get update && \
	apt-get -q -y install php-intl php-soap postgresql-client composer && \
	apt-get autoremove -y && \
	a2enmod rewrite headers cache_disk

WORKDIR /var/www
COPY --from=builder /var/lib/jenkins/www /var/www

RUN rm -rf change_branch.sh .editorconfig .gitattributes html

COPY --from=builder /var/lib/jenkins/www/bibdk-backend-settings/conf/fqdn.conf /etc/apache2/conf-available/
COPY --from=builder /var/lib/jenkins/www/bibdk-backend-settings/conf/000-default.conf /etc/apache2/sites-enabled/
COPY --from=builder /var/lib/jenkins/www/bibdk-backend-settings/conf/settings.php /var/www/web/sites/default/
COPY --from=builder /var/lib/jenkins/www/bibdk-backend-settings/conf/.env /
ADD --chown=www-data:www-data ["https://is.dbc.dk/view/frontend/job/bibliotekdk-next/job/Fetch%20bibdk-backend%20files/lastSuccessfulBuild/artifact/files.tar.gz", "/tmp/"]
ADD script/run_dev_start.sh /
ADD script/run_master_start.sh /
ADD script/config_memcache.sh /

RUN mkdir ${APACHE_ROOT}/sites/default/files
RUN mkdir ${APACHE_ROOT}/sites/default/files/config_bibdk
RUN chown -R www-data:www-data /var/www/web
RUN chmod -R 775 ${APACHE_ROOT}/sites/default/files
