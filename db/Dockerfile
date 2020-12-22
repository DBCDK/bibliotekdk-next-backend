FROM docker.dbc.dk/dbc-postgres

# Environment settings: Read setup from configmap
ENV POSTGRES_USER=filestore
ENV POSTGRES_DB=filestore
ENV POSTGRES_PASSWORD=filestore

USER root
ADD --chown=postgres:postgres ["https://is.dbc.dk/view/frontend/job/bibliotekdk-next/job/Fetch%20bibdk-backend-develop%20database/lastSuccessfulBuild/artifact/bibdk_backend_db_sql.tar.gz", "/docker-entrypoint.d/"]
RUN tar xf /docker-entrypoint.d/bibdk_backend_db_sql.tar.gz -C /docker-entrypoint.d && \
    rm /docker-entrypoint.d/bibdk_backend_db_sql.tar.gz
USER $POSTGRES_LINUX_USER
