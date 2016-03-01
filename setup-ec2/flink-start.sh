#!/bin/bash -x

set -e

PROCZERO=$(hostname -i)

echo "Starting Flink JobManager on $PROCZERO"
$FLINK_HOME/bin/jobmanager.sh start cluster batch $PROCZERO

sed -ie "s/^jobmanager.rpc.address:.*$/jobmanager.rpc.address: $PROCZERO/" $FLINK_HOME/conf/flink-conf.yaml

# disable absolute memory settings.
sed -ie "s/^jobmanager.heap.mb:.*$/jobmanager.heap.mb: 512/" $FLINK_HOME/conf/flink-conf.yaml
sed -ie "s/^taskmanager.heap.mb:.*$/taskmanager.heap.mb: 28000/" $FLINK_HOME/conf/flink-conf.yaml
sed -ie "s/^taskmanager.numberOfTaskSlots:.*$/taskmanager.numberOfTaskSlots: 4/" $FLINK_HOME/conf/flink-conf.yaml
sed -ie "s/^parallelism.default:.*$/parallelism.default: 4/" $FLINK_HOME/conf/flink-conf.yaml

for IP in $(cat ~/boxes.txt); do
    echo "Starting Flink TaskManager on $IP"

    ssh $IP "$FLINK_HOME/bin/taskmanager.sh start batch"
done
