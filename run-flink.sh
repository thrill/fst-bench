#!/bin/bash -x

set -e

# unset ssh-agent to use local keys only
unset SSH_AUTH_SOCK

# get first host's IP from thrill's host:port list
[[ $THRILL_HOSTLIST =~ ^([0-9.]+): ]] || exit 1
PROCZERO=${BASH_REMATCH[1]}

# start Flink's JobManager
if [ "$SLURM_PROCID" == 0 ]; then
    $FLINK_HOME/bin/jobmanager.sh stop cluster batch || true
    echo "Starting Spark Master on $(hostname)"
    $FLINK_HOME/bin/jobmanager.sh start cluster batch 172.26.20.1
else
    sleep 2s
fi

# start Flink's TaskManager
$FLINK_HOME/bin/taskmanager.sh stop batch || true

SLAVE_MEM=$(($(ulimit -v) * 3 / 4))
SLAVE_ARGS=""

if [ "$SLURM_PROCID" == 0 ]; then
    $FLINK_HOME/bin/taskmanager.sh start batch
    sync

    echo "Running application $@"
    "$@"

    $FLINK_HOME/bin/taskmanager.sh stop batch || true
    echo "Stopping Flink JobManager on $(hostname)"
    $FLINK_HOME/bin/jobmanager.sh stop cluster batch || true
    # signal srun to terminate the other tasks
    exit 1
else
    # launch Flink TaskManager
    $FLINK_HOME/bin/taskmanager.sh start batch
    PID_FILE=/tmp/flink-$USER-taskmanager.pid
    while ps -p `cat $PID_FILE` > /dev/null; do sleep 1m; done
fi
