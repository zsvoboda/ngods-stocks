ARG metabase_repo=metabase
ARG metabase_version=latest
FROM metabase/${metabase_repo}:${metabase_version} as metabase

FROM openjdk:19-slim-bullseye

ENV FC_LANG en-US LC_CTYPE en_US.UTF-8

ENV MB_DB_FILE="/conf/metabase.db" \
    MB_DB_HOST="0.0.0.0" \
    MB_JETTY_PORT="3030" \
    MB_DB_TYPE="h2" \
    MB_PLUGINS_DIR="/plugins"

# dependencies
RUN apt-get update -yq && apt-get install -yq bash fonts-dejavu-core fonts-dejavu-extra fontconfig curl openjdk-11-jre-headless && \
    apt-get clean && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/ && \
    mkdir -p /app/certs && \
    curl https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem -o /app/certs/rds-combined-ca-bundle.pem  && \
    keytool -noprompt -import -trustcacerts -alias aws-rds -file /app/certs/rds-combined-ca-bundle.pem -keystore /etc/ssl/certs/java/cacerts -keypass changeit -storepass changeit && \
    curl https://cacerts.digicert.com/DigiCertGlobalRootG2.crt.pem -o /app/certs/DigiCertGlobalRootG2.crt.pem  && \
    keytool -noprompt -import -trustcacerts -alias azure-cert -file /app/certs/DigiCertGlobalRootG2.crt.pem -keystore /etc/ssl/certs/java/cacerts -keypass changeit -storepass changeit && \
    mkdir -p /plugins && chmod a+rwx /plugins && \
    mkdir -p $(dirname ${MB_DB_FILE}) && chmod a+rwx $(dirname ${MB_DB_FILE}) && \
    useradd --shell /bin/bash metabase


WORKDIR /app
USER metabase

# copy app from the offical image
COPY --from=metabase --chown=metabase /app /app

# expose our default runtime port
EXPOSE 3030

# run it
ENTRYPOINT ["/app/run_metabase.sh"]