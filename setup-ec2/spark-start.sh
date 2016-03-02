#!/bin/bash -x

set -e

cd $SPARK_HOME/

PROCZERO=$(hostname -i)

echo "Starting Spark Master on $PROCZERO"
$SPARK_HOME/sbin/start-master.sh -h 0.0.0.0

for IP in $(cat ~/boxes.txt); do
    echo "Starting Spark Slave on $IP"

    ssh $IP "cd $SPARK_HOME && $SPARK_HOME/sbin/start-slave.sh --memory 26000MB spark://$PROCZERO:7077"
done
