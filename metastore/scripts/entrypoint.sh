#!/bin/sh

export HADOOP_VERSION=3.2.0
export METASTORE_VERSION=3.0.0

export HADOOP_HOME=/opt/hadoop
export HIVE_HOME=/opt/metastore

export HADOOP_CLASSPATH=${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar:${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-3.2.0.jar
export METASTORE_DB_HOSTNAME=postgres

echo "Waiting for database on ${METASTORE_DB_HOSTNAME} to launch on 5432 ..."

while ! nc -z ${METASTORE_DB_HOSTNAME} 5432; do
  sleep 1
done

echo "Database on ${METASTORE_DB_HOSTNAME}:5432 started"
echo "Init apache hive metastore on ${METASTORE_DB_HOSTNAME}:5432"

${HIVE_HOME}/bin/schematool -initSchema -dbType postgres
${HIVE_HOME}/bin/start-metastore