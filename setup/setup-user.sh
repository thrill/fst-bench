#!/bin/bash -x

set -e

# Make sure only a non-root user can run our script
if [ "$(id -u)" == "0" ]; then
   echo "This script must be run as a user" 1>&2
   exit 1
fi

DIR=`dirname "$0"`

source $DIR/env.sh

mkdir -p ~/local/

# Scala Installation

if [ ! -e ${SCALA_HOME} ]; then

    wget http://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz

    tar xzf scala-${SCALA_VERSION}.tgz
    rm -f scala-${SCALA_VERSION}.tgz

    mv scala-* ${SCALA_HOME}

fi

# Maven Installation

if [ ! -e ${M2_HOME} ]; then

    wget https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/${MAVEN_VERSION}/apache-maven-${MAVEN_VERSION}-bin.tar.gz
    tar xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz
    rm -f apache-maven-${MAVEN_VERSION}-bin.tar.gz
    mv apache-maven-* ${M2_HOME}

fi

# Hadoop Installation

if [ ! -e ~/local/hadoop-${HADOOP_VERSION_DETAIL} ]; then

    wget http://mirror.reverse.net/pub/apache/hadoop/core/hadoop-${HADOOP_VERSION_DETAIL}/hadoop-${HADOOP_VERSION_DETAIL}.tar.gz
    tar xzf hadoop-*.tar.gz -C ~/local/
    rm -f hadoop-*.tar.gz

fi

# SPARK Installation

if [ ! -e ${SPARK_HOME} ]; then

    wget http://mirror.reverse.net/pub/apache/spark/spark-${SPARK_VERSION_DETAIL}/spark-${SPARK_VERSION_DETAIL}-bin-hadoop${HADOOP_FOR_SPARK_VERSION}.tgz
    tar xzf spark-*.tgz
    rm -f spark-*.tgz
    mv spark-* ${SPARK_HOME}

fi

# FLINK Installation

if [ ! -e ${FLINK_HOME} ]; then

    wget http://mirror.reverse.net/pub/apache/flink/flink-${FLINK_VERSION_DETAIL}/flink-${FLINK_VERSION_DETAIL}-bin-hadoop${HADOOP_FOR_FLINK_VERSION}-scala_${SCALA_FOR_FLINK_VERSION}.tgz
    tar xzf flink-*.tgz
    rm -f flink-*.tgz
    mv flink-* ${FLINK_HOME}

fi
