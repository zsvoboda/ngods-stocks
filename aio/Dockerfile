# syntax=docker/dockerfile:1
FROM python:3.9-bullseye

ENV METASTORE_HADOOP_VERSION=3.2.0
ENV METASTORE_VERSION=3.0.0
ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/metastore
ENV SPARK_HOME=/opt/spark
ENV DAGSTER_HOME=/opt/dagster
ENV KYUUBI_HOME=/opt/kyuubi
ENV BIN_DIR=/usr/bin

ENV DAGSTER_DIR=/var/lib/ngods/dagster
ENV DBT_DIR=/var/lib/ngods/dbt
ENV NOTEBOOKS_DIR=/var/lib/ngods/notebooks
ENV DATA_STAGE_DIR=/var/lib/ngods/stage
ENV HTML_DIR=/var/lib/ngods/html

# Add iceberg spark runtime jar to IJava classpath
ENV IJAVA_CLASSPATH=/opt/spark/jars/*
ENV PATH="/opt/spark/sbin:/opt/spark/bin:${PATH}"
ENV INSTALL_DIR=/tmp/install

RUN mkdir -p ${HADOOP_HOME} ${SPARK_HOME} ${HIVE_HOME} ${MINIO_HOME}/bin ${DAGSTER_HOME}  ${KYUUBI_HOME} \ 
             ${DAGSTER_DIR} ${DBT_DIR} ${DATA_STAGE_DIR} ${NOTEBOOKS_DIR} ${INSTALL_DIR} ${HTML_DIR} \
            /root/.ipython/profile_default/startup

# install core packages 
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      sudo \
      curl \
      unzip \
      make \
      openjdk-11-jdk \
      build-essential \
      software-properties-common \
      libpq-dev \
      gcc \
      g++ \
      libsasl2-dev \
		  libsasl2-2\ 
		  libsasl2-modules-gssapi-mit\
      unixodbc-dev \
      ssh \
      postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${INSTALL_DIR}

# Install python deps
COPY conf/requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt \
    && rm requirements.txt

# Download and install IJava jupyter kernel
RUN curl https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip -Lo ijava-1.3.0.zip \
  && unzip ijava-1.3.0.zip \
  && python3 install.py --sys-prefix \
  && rm -rf ijava-1.3.0.zip	install.py java \
# Download spark distribution and install it
  && curl https://archive.apache.org/dist/spark/spark-3.3.0/spark-3.3.0-bin-hadoop3.tgz -o spark-3.3.0-bin-hadoop3.tgz \
    && tar xvzf spark-3.3.0-bin-hadoop3.tgz --directory /opt/spark --strip-components 1 \
    && rm spark-3.3.0-bin-hadoop3.tgz \
# Download iceberg spark runtime
  && curl https://search.maven.org/remotecontent?filepath=org/apache/iceberg/iceberg-spark-runtime-3.3_2.12/0.14.0/iceberg-spark-runtime-3.3_2.12-0.14.0.jar -Lo iceberg-spark-runtime-3.3_2.12-0.14.0.jar \
    && mv iceberg-spark-runtime-3.3_2.12-0.14.0.jar /opt/spark/jars \
# Download Java AWS SDK
  && curl https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.17.247/bundle-2.17.247.jar -Lo bundle-2.17.247.jar \
    && mv bundle-2.17.247.jar /opt/spark/jars \
# Download URL connection client required for S3FileIO
  && curl https://repo1.maven.org/maven2/software/amazon/awssdk/url-connection-client/2.17.247/url-connection-client-2.17.247.jar -Lo url-connection-client-2.17.247.jar \
     && mv url-connection-client-2.17.247.jar /opt/spark/jars \
# Install AWS CLI
  && curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip \
    && unzip awscliv2.zip \
    && sudo ./aws/install \
    && rm awscliv2.zip \
    && rm -rf aws/ \
# Download and install haddop for metastore 
  && curl https://archive.apache.org/dist/hadoop/common/hadoop-${METASTORE_HADOOP_VERSION}/hadoop-${METASTORE_HADOOP_VERSION}.tar.gz -Lo hadoop.tgz \
    && tar xvzf hadoop.tgz --directory ${HADOOP_HOME} --strip-components 1 \
    && rm hadoop.tgz \
# Download and install Hive metastore
  && curl https://downloads.apache.org/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz -Lo hive.tgz \ 
    && tar xvzf hive.tgz --directory ${HIVE_HOME} --strip-components 1 \
    && rm hive.tgz \
# Download and install Kyuubi JDBC
  && curl https://dlcdn.apache.org/incubator/kyuubi/kyuubi-1.5.2-incubating/apache-kyuubi-1.5.2-incubating-bin.tgz -Lo kyuubi.tgz \ 
    && tar xvzf kyuubi.tgz --directory ${KYUUBI_HOME} --strip-components 1 \
    && rm kyuubi.tgz \
# Download and install Postgres deiver for Hive metastore
  && curl https://repo1.maven.org/maven2/org/postgresql/postgresql/42.4.0/postgresql-42.4.0.jar -Lo pgsql.jar \ 
    && mv pgsql.jar ${HIVE_HOME}/lib 

WORKDIR ${SPARK_HOME}

COPY conf/spark-defaults.conf ${SPARK_HOME}/conf
COPY conf/metastore-site.xml ${HIVE_HOME}/conf
COPY conf/dagster.yaml ${DAGSTER_HOME}
COPY scripts/entrypoint.sh ${BIN_DIR}
COPY conf/ipython/startup/00-prettytables.py /root/.ipython/profile_default/startup
COPY conf/ipython/startup/README /root/.ipython/profile_default/startup
COPY conf/notebook ${BIN_DIR}/notebook
COPY conf/notebook ${BIN_DIR}/pyspark-notebook

RUN chmod u+x ${SPARK_HOME}/* \
  && chmod u+x ${SPARK_HOME}/bin/* \
  && chmod u+x ${HIVE_HOME}/bin/* \
  && chmod u+x ${BIN_DIR}/notebook \
  && chmod u+x ${BIN_DIR}/pyspark-notebook

EXPOSE 3070
EXPOSE 8888
EXPOSE 7077
EXPOSE 8061
EXPOSE 8062
EXPOSE 10000
EXPOSE 10009
EXPOSE 18080
EXPOSE 9083


ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["notebook"]