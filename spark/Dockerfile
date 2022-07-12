# syntax=docker/dockerfile:1
FROM python:3.9-bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      sudo \
      curl \
      vim \
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
      ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV DAGSTER_HOME=/opt/dagster/dagster_home/
RUN mkdir -p /opt/dagster/dagster_home /opt/dagster/app /opt/dagster/dbt
COPY dagster.yaml /opt/dagster/dagster_home/

# Install Jupyter and other python deps
COPY requirements.txt .
RUN pip3 install -r requirements.txt


# Download and install IJava jupyter kernel
RUN curl https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip -Lo ijava-1.3.0.zip \
  && unzip ijava-1.3.0.zip \
  && python3 install.py --sys-prefix \
  && rm ijava-1.3.0.zip

## Download spark and hadoop dependencies and install

# Optional env variables
ENV SPARK_HOME=${SPARK_HOME:-"/opt/spark"}
ENV HADOOP_HOME=${HADOOP_HOME:-"/opt/hadoop"}

RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${SPARK_HOME}
WORKDIR ${SPARK_HOME}

# Download spark
RUN curl https://dlcdn.apache.org/spark/spark-3.2.1/spark-3.2.1-bin-hadoop3.2.tgz -o spark-3.2.1-bin-hadoop3.2.tgz \
 && tar xvzf spark-3.2.1-bin-hadoop3.2.tgz --directory /opt/spark --strip-components 1 \
 && rm -rf spark-3.2.1-bin-hadoop3.2.tgz

# Download iceberg spark runtime
RUN curl https://search.maven.org/remotecontent?filepath=org/apache/iceberg/iceberg-spark-runtime-3.2_2.12/0.13.1/iceberg-spark-runtime-3.2_2.12-0.13.1.jar -Lo iceberg-spark-runtime-3.2_2.12-0.13.1.jar \
 && mv iceberg-spark-runtime-3.2_2.12-0.13.1.jar /opt/spark/jars

# Download Java AWS SDK
RUN curl https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.17.165/bundle-2.17.165.jar -Lo bundle-2.17.165.jar \
 && mv bundle-2.17.165.jar /opt/spark/jars

# Download URL connection client required for S3FileIO
RUN curl https://repo1.maven.org/maven2/software/amazon/awssdk/url-connection-client/2.17.165/url-connection-client-2.17.165.jar -Lo url-connection-client-2.17.165.jar \
 && mv url-connection-client-2.17.165.jar /opt/spark/jars

# Download URL connection client required for AWS
RUN curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk/1.12.222/aws-java-sdk-1.12.222.jar -Lo aws-java-sdk-1.12.222.jar \
 && mv aws-java-sdk-1.12.222.jar /opt/spark/jars

# Download URL connection client required for AWS
RUN curl https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.1/hadoop-aws-3.2.1.jar -Lo hadoop-aws-3.2.1.jar \
 && mv hadoop-aws-3.2.1.jar /opt/spark/jars

# Download URL connection client required for AWS
RUN curl https://repo1.maven.org/maven2/net/java/dev/jets3t/jets3t/0.9.4/jets3t-0.9.4.jar -Lo jets3t-0.9.4.jar \
 && mv jets3t-0.9.4.jar /opt/spark/jars

# Download URL connection client required for AWS
RUN curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-s3/1.12.222/aws-java-sdk-s3-1.12.222.jar -Lo aws-java-sdk-s3-1.12.222.jar \
 && mv aws-java-sdk-s3-1.12.222.jar /opt/spark/jars

# Download URL connection client required for AWS
RUN curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-core/1.12.222/aws-java-sdk-core-1.12.222.jar -Lo aws-java-sdk-core-1.12.222.jar \
 && mv aws-java-sdk-core-1.12.222.jar /opt/spark/jars

# Download URL connection client required for AWS
RUN curl https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-dynamodb/1.12.222/aws-java-sdk-dynamodb-1.12.222.jar -Lo aws-java-sdk-dynamodb-1.12.222.jar \
 && mv aws-java-sdk-dynamodb-1.12.222.jar /opt/spark/jars


# Add iceberg spark runtime jar to IJava classpath
ENV IJAVA_CLASSPATH=/opt/spark/jars/*

RUN mkdir -p /home/iceberg/localwarehouse /home/iceberg/notebooks /home/iceberg/warehouse /home/iceberg/data /home/data/stage /home/iceberg/spark-events

# Add a notebook command
RUN echo '#! /bin/sh' >> /bin/notebook \
 && echo 'export PYSPARK_DRIVER_PYTHON=jupyter-notebook' >> /bin/notebook \
 && echo "export PYSPARK_DRIVER_PYTHON_OPTS=\"--notebook-dir=/home/iceberg/notebooks --ip='*' --NotebookApp.token='' --NotebookApp.password='' --port=8888 --no-browser --allow-root\"" >> /bin/notebook \
 && echo "pyspark" >> /bin/notebook \
 && chmod u+x /bin/notebook

# Add a pyspark-notebook command (alias for notebook command for backwards-compatibility)
RUN echo '#! /bin/sh' >> /bin/pyspark-notebook \
 && echo 'export PYSPARK_DRIVER_PYTHON=jupyter-notebook' >> /bin/pyspark-notebook \
 && echo "export PYSPARK_DRIVER_PYTHON_OPTS=\"--notebook-dir=/home/iceberg/notebooks --ip='*' --NotebookApp.token='' --NotebookApp.password='' --port=8888 --no-browser --allow-root\"" >> /bin/pyspark-notebook \
 && echo "pyspark" >> /bin/pyspark-notebook \
 && chmod u+x /bin/pyspark-notebook

RUN mkdir -p /root/.ipython/profile_default/startup
COPY ipython/startup/00-prettytables.py /root/.ipython/profile_default/startup
COPY ipython/startup/README /root/.ipython/profile_default/startup

COPY spark-defaults.conf /opt/spark/conf
ENV PATH="/opt/spark/sbin:/opt/spark/bin:${PATH}"
ENV SPARK_HOME="/opt/spark"

RUN chmod u+x /opt/spark/sbin/* && \
    chmod u+x /opt/spark/bin/*

COPY entrypoint.sh .

EXPOSE 3070

ENTRYPOINT ["./entrypoint.sh"]
CMD ["notebook"]
