#!/bin/bash -x

set -e

DIR=`dirname "$0"`

PROCZERO=$(hostname -i)

echo "Starting Spark Master on $PROCZERO"
$SPARK_HOME/sbin/start-master.sh -h 0.0.0.0

for IP in $(cat ~/boxes.txt); do
    echo "Starting Spark Slave on $IP"

    ssh $IP "cd $SPARK_HOME && $SPARK_HOME/sbin/start-slave.sh --memory 24000MB spark://$PROCZERO:7077"
done

# write default parallelism config file
parallelism=$(cat ~/boxes.txt | wc -l)
parallelism=$((parallelism * 4))

pwd
cat <<EOF | tee ${DIR}/../conf/99-zzz-automatic.conf
# execute parallelism settings
hibench.default.map.parallelism		${parallelism}
hibench.default.shuffle.parallelism	${parallelism}

# YARN resource configuration
hibench.yarn.executor.num	${parallelism}
hibench.yarn.executor.cores	${parallelism}
EOF
