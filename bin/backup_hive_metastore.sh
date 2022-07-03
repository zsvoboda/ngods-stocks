#!/bin/bash

export BIN_DIR="`dirname \"$0\"`"
export NGODS_HOME="$( cd "${BIN_DIR}/.." && pwd )"

# hive-password
mysqldump -u hive -p --no-tablespaces metastore > hive_metastore_backup_20220606.sql

gsutil cp hive_metastore_backup_20220606.sql gs://zsvoboda-dataproc/backup

#gsutil cp gs://zsvoboda-dataproc/backup/hive_metastore_backup_20220606.sql .
#mysql -u hive -p metastore < hive_metastore_backup_20220606.sql