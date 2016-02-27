#!/bin/bash -x

set -e

# unset ssh-agent to use local keys only
unset SSH_AUTH_SOCK

# get first host's IP from thrill's host:port list
[[ $THRILL_HOSTLIST =~ ^([0-9.]+): ]] || exit 1
PROCZERO=${BASH_REMATCH[1]}

# start Spark Master
if [ "$SLURM_PROCID" == 0 ]; then
    $SPARK_HOME/sbin/stop-master.sh || true
    echo "Starting Spark Master on $(hostname)"
    $SPARK_HOME/sbin/start-master.sh -h 0.0.0.0
else
    sleep 2s
fi

# start Spark Slave
$SPARK_HOME/sbin/stop-slave.sh || true

SLAVE_MEM=$(($(ulimit -v) * 3 / 4))
SLAVE_ARGS="--cores $THRILL_WORKERS_PER_HOST --memory ${SLAVE_MEM}KB --work-dir /tmp/spark-$USER-$$/"

if [ "$SLURM_PROCID" == 0 ]; then
    $SPARK_HOME/sbin/start-slave.sh spark://$PROCZERO:7077 $SLAVE_ARGS
    sync

    echo "Running application $@"
    "$@"

    $SPARK_HOME/sbin/stop-slave.sh || true
    echo "Stopping Spark Master on $(hostname)"
    $SPARK_HOME/sbin/stop-master.sh || true
    # signal srun to terminate the other tasks
    exit 1
else
    # launch spark slave in foreground
    $SPARK_HOME/bin/spark-class \
        org.apache.spark.deploy.worker.Worker \
        spark://$PROCZERO:7077 $SLAVE_ARGS
fi
