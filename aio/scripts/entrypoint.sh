#!/bin/bash

export JAVA_HOME="$(jrunscript -e 'java.lang.System.out.println(java.lang.System.getProperty("java.home"));')"
export HADOOP_HOME=/opt/hadoop
export HIVE_HOME=/opt/metastore
export MINIO_HOME=/opt/minio
export MINIO_DATA_ROOT=/data

export METASTORE_HADOOP_VERSION=3.2.0
export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-${METASTORE_HADOOP_VERSION}.jar
#export MINIO_ROOT_USER=minio
#export MINIO_ROOT_PASSWORD=minio123

# pgsql
sudo -u postgres /usr/lib/postgresql/13/bin/postgres -D /var/lib/postgresql/13/main -c config_file=/etc/postgresql/13/main/postgresql.conf &


# minio
${MINIO_HOME}/bin/minio server ${MINIO_DATA_ROOT} --console-address ":9001" &
until (${MINIO_HOME}/bin/mc config host add minio http://minio:9000 minio minio123) do echo '...waiting...' && sleep 1; done;
${MINIO_HOME}/bin/mc mb minio/warehouse
${MINIO_HOME}/bin/mc policy set public minio/warehouse

# spark
mkdir -p /tmp/spark-events
start-master.sh -p 7077 --webui-port 8061
start-worker.sh spark://spark:7077 --webui-port 8062
start-history-server.sh
start-thriftserver.sh --hiveconf hive.server2.thrift.port 10000 --hiveconf hive.server2.authentication NOSASL

# metastore 
${HIVE_HOME}/bin/schematool -initSchema -dbType postgres
${HIVE_HOME}/bin/start-metastore &

# trino
/usr/lib/trino/bin/launcher start

# dagster
cd /opt/dagster/app && dagit -h 0.0.0.0 -p 3070 &

# Entrypoint, for example notebook, pyspark or spark-sql
if [[ $# -gt 0 ]] ; then
    eval "$1"
fi
