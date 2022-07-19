# syntax=docker/dockerfile:1
FROM python:3.9-bullseye

ENV METASTORE_HADOOP_VERSION=3.2.0
ENV METASTORE_VERSION=3.0.0
ENV HADOOP_HOME=/opt/hadoop
ENV HIVE_HOME=/opt/metastore
ENV SPARK_HOME=/opt/spark
ENV DAGSTER_HOME=/opt/dagster
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

RUN mkdir -p ${HADOOP_HOME} ${SPARK_HOME} ${HIVE_HOME} ${MINIO_HOME}/bin ${DAGSTER_HOME}  \ 
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
# Download aprk distrotion and install it
  && curl https://archive.apache.org/dist/spark/spark-3.2.2/spark-3.2.2-bin-hadoop3.2.tgz -o spark-3.2.2-bin-hadoop3.2.tgz \
    && tar xvzf spark-3.2.2-bin-hadoop3.2.tgz --directory /opt/spark --strip-components 1 \
    && rm spark-3.2.2-bin-hadoop3.2.tgz \
# Download iceberg spark runtime
  && curl https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.2_2.12/0.13.2/iceberg-spark-runtime-3.2_2.12-0.13.2.jar -Lo iceberg-spark-runtime-3.2_2.12-0.13.2.jar \
    && mv iceberg-spark-runtime-3.2_2.12-0.13.2.jar /opt/spark/jars \
# Download Java AWS SDK
  && curl https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.17.165/bundle-2.17.165.jar -Lo bundle-2.17.165.jar \
    && mv bundle-2.17.165.jar /opt/spark/jars \
# Download URL connection client required for S3FileIO
  && curl https://repo1.maven.org/maven2/software/amazon/awssdk/url-connection-client/2.17.165/url-connection-client-2.17.165.jar -Lo url-connection-client-2.17.165.jar \
     && mv url-connection-client-2.17.165.jar /opt/spark/jars \
# Download AWS Java SDK for S3FileIO
  && curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.12.222/aws-java-sdk-1.12.222.jar -Lo aws-java-sdk-1.12.222.jar \
     && mv aws-java-sdk-1.12.222.jar /opt/spark/jars \
# Download AWS Hadoop distrotion and install it
  && curl https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.1/hadoop-aws-3.2.1.jar -Lo hadoop-aws-3.2.1.jar \
    && mv hadoop-aws-3.2.1.jar /opt/spark/jars \
# Download Jets3t for S3FileIO
  && curl https://repo1.maven.org/maven2/net/java/dev/jets3t/jets3t/0.9.4/jets3t-0.9.4.jar -Lo jets3t-0.9.4.jar \
    && mv jets3t-0.9.4.jar /opt/spark/jars \
# Download AWS S3 File IO
  && curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-s3/1.12.222/aws-java-sdk-s3-1.12.222.jar -Lo aws-java-sdk-s3-1.12.222.jar \
    && mv aws-java-sdk-s3-1.12.222.jar /opt/spark/jars \
# Download AWS SDK for S3FileIO
  && curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/1.12.222/aws-java-sdk-core-1.12.222.jar -Lo aws-java-sdk-core-1.12.222.jar \
    && mv aws-java-sdk-core-1.12.222.jar /opt/spark/jars \
# Download AWS DynamoDB SDK for S3FileIO
  && curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-dynamodb/1.12.222/aws-java-sdk-dynamodb-1.12.222.jar -Lo aws-java-sdk-dynamodb-1.12.222.jar \
    && mv aws-java-sdk-dynamodb-1.12.222.jar /opt/spark/jars \
# Download and install haddop for metastore 
  && curl https://archive.apache.org/dist/hadoop/common/hadoop-${METASTORE_HADOOP_VERSION}/hadoop-${METASTORE_HADOOP_VERSION}.tar.gz -Lo hadoop.tgz \
    && tar xvzf hadoop.tgz --directory ${HADOOP_HOME} --strip-components 1 \
    && rm hadoop.tgz \
# Download and install Hive metastore
  && curl https://downloads.apache.org/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz -Lo hive.tgz \ 
    && tar xvzf hive.tgz --directory ${HIVE_HOME} --strip-components 1 \
    && rm hive.tgz \
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
EXPOSE 18080
EXPOSE 9083


ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["notebook"]