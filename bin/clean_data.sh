#!/bin/bash

export BIN_DIR="`dirname \"$0\"`"
export NGODS_HOME="$( cd "${BIN_DIR}/.." && pwd )"

cd ${NGODS_HOME}/data/mariadb && rm -rf * .* 
cd ${NGODS_HOME}/data/minio && rm -rf * .* 
cd ${NGODS_HOME}/data/trino && rm -rf * .* 
cd ${NGODS_HOME}/data/postgres && rm -rf * .* 
# cd ${NGODS_HOME}/data/spark && rm -rf * .* 
cd ${NGODS_HOME}/data/elasticsearch && rm -rf * .* 
cd ${NGODS_HOME}/data/zookeeper && rm -rf * .* 
cd ${NGODS_HOME}/data/zookeeper && rm -rf *.html 