FROM openjdk:19-slim-bullseye

WORKDIR /opt

ENV HADOOP_VERSION=3.2.0
ENV METASTORE_VERSION=3.0.0

ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/metastore
ENV MYSQL_HOME=/opt/mysql

RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${HIVE_HOME} && mkdir -p ${MYSQL_HOME}

RUN apt-get update && apt-get install -y netcat curl

RUN curl https://downloads.apache.org/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz \ 
    -Lo hive.tgz && tar xvzf hive.tgz --directory ${HIVE_HOME} --strip-components 1  && rm -rf hive.tgz

RUN curl https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -Lo hadoop.tgz && \ 
    tar xvzf hadoop.tgz --directory ${HADOOP_HOME} --strip-components 1  && rm -rf hadoop.tgz

RUN curl https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz -Lo mysql.tgz && \ 
    tar xvzf mysql.tgz --directory ${MYSQL_HOME} --strip-components 1  && rm -rf mysql.tgz && \
    cp ${MYSQL_HOME}/mysql-connector-java-8.0.19.jar ${HIVE_HOME}/lib/ && \
    rm -rf  mysql.tgz

RUN curl https://jdbc.postgresql.org/download/postgresql-42.4.0.jar -Lo postgresql-42.4.0.jar \ 
    && mv postgresql-42.4.0.jar ${HIVE_HOME}/lib


COPY scripts/entrypoint.sh /entrypoint.sh

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive /entrypoint.sh && chmod +x /entrypoint.sh

USER hive
EXPOSE 9083

ENTRYPOINT ["sh", "-c", "/entrypoint.sh"]
