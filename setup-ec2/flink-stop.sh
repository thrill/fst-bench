#!/bin/bash -x

set -e

cd $SPARK_HOME/

PROCZERO=$(hostname -i)

for IP in $(cat ~/boxes.txt); do
    echo "Stopping Flink TaskManager on $IP"

    ssh $IP "$FLINK_HOME/bin/taskmanager.sh stop batch"
done

echo "Stopping Flink JobManager on $PROCZERO"
$FLINK_HOME/bin/jobmanager.sh stop
