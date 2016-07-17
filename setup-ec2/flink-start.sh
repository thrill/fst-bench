#!/bin/bash -x

set -e

PROCZERO=$(hostname -i)

echo "Starting Flink JobManager on $PROCZERO"
$FLINK_HOME/bin/jobmanager.sh start cluster $PROCZERO

sed -ie "s/^jobmanager.rpc.address:.*$/jobmanager.rpc.address: $PROCZERO/" $FLINK_HOME/conf/flink-conf.yaml

# disable absolute memory settings.
sed -ie "s/^jobmanager.heap.mb:.*$/jobmanager.heap.mb: 512/" $FLINK_HOME/conf/flink-conf.yaml
sed -ie "s/^taskmanager.heap.mb:.*$/taskmanager.heap.mb: 200000/" $FLINK_HOME/conf/flink-conf.yaml
sed -ie "s/^taskmanager.numberOfTaskSlots:.*$/taskmanager.numberOfTaskSlots: 32/" $FLINK_HOME/conf/flink-conf.yaml

parallelism=$(cat ~/boxes.txt | wc -l)
parallelism=$((parallelism * 32))
sed -ie "s/^parallelism.default:.*$/parallelism.default: $parallelism/" $FLINK_HOME/conf/flink-conf.yaml

buffers=$(cat ~/boxes.txt | wc -l)
buffers=$((buffers * 10000))
sed -ie "s/^.*taskmanager.network.numberOfBuffers: .*$/taskmanager.network.numberOfBuffers: $buffers/" $FLINK_HOME/conf/flink-conf.yaml

for IP in $(cat ~/boxes.txt); do
    echo "Starting Flink TaskManager on $IP"

    ssh $IP "$FLINK_HOME/bin/taskmanager.sh start batch"
done
sleep 20s
