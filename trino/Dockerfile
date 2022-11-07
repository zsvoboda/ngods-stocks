# syntax=docker/dockerfile:1
FROM python:3.9-bullseye

ENV TRINO_HOME=/opt/trino
ENV BIN_DIR=/usr/bin

ENV DATA_STAGE_DIR=/var/lib/ngods/stage
ENV TRINO_DATA_DIR=/var/lib/trino/data
ENV INSTALL_DIR=/tmp/install

RUN mkdir -p ${TRINO_HOME} ${TRINO_DATA_DIR} ${DATA_STAGE_DIR} ${INSTALL_DIR}

# install core packages 
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      sudo \
      curl \
      unzip \
      make \
      openjdk-17-jdk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${INSTALL_DIR}

# Install python deps
COPY conf/requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt \
    && rm requirements.txt

RUN curl https://repo1.maven.org/maven2/io/trino/trino-server/402/trino-server-402.tar.gz -Lo trino-server-402.tar.gz \
    && tar xvzf trino-server-402.tar.gz --directory ${TRINO_HOME} --strip-components 1 \
    && rm trino-server-402.tar.gz 

WORKDIR ${TRINO_HOME}

COPY conf/trino/ ${TRINO_HOME}/etc

RUN chmod u+x ${TRINO_HOME}/bin/* 

EXPOSE 8060
EXPOSE 8063

CMD ["/opt/trino/bin/launcher", "run"]