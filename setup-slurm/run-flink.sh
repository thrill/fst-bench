#!/bin/bash -x

set -e

# unset ssh-agent to use local keys only
unset SSH_AUTH_SOCK

# get first host's IP from thrill's host:port list
[[ $THRILL_HOSTLIST =~ ^([0-9.]+): ]] || exit 1
PROCZERO=${BASH_REMATCH[1]}

# start Flink's JobManager
if [ "$SLURM_PROCID" == 0 ]; then
    $FLINK_HOME/bin/jobmanager.sh stop cluster || true

    # write Flink settings
    sed -ie "s/^jobmanager.rpc.address:.*$/jobmanager.rpc.address: $PROCZERO/" $FLINK_HOME/conf/flink-conf.yaml

    # disable absolute memory settings.
    sed -ie "s/^jobmanager.heap.mb:.*$/jobmanager.heap.mb: 512/" $FLINK_HOME/conf/flink-conf.yaml
    sed -ie "s/^taskmanager.heap.mb:.*$/taskmanager.heap.mb: 48000/" $FLINK_HOME/conf/flink-conf.yaml

    parallelism=$((SLURM_NNODES * THRILL_WORKERS_PER_HOST))
    sed -ie "s/^parallelism.default:.*$/parallelism.default: $parallelism/" $FLINK_HOME/conf/flink-conf.yaml
    sed -ie "s/^taskmanager.numberOfTaskSlots:.*$/taskmanager.numberOfTaskSlots: $parallelism/" $FLINK_HOME/conf/flink-conf.yaml

    echo "Starting Flink Master on $(hostname)"
    $FLINK_HOME/bin/jobmanager.sh start cluster
else
    sleep 2s
fi

# start Flink's TaskManager
$FLINK_HOME/bin/taskmanager.sh stop || true

SLAVE_MEM=$(($(ulimit -v) * 3 / 4))
SLAVE_ARGS=""

# start Thrill system profiler
PROFILE=~/fst-bench/report/$BENCHMARK/scale=${SCALE}_hosts=${SLURM_NNODES}_run=${RUN}/$SUBMARK/
echo "System profiler: $PROFILE"
mkdir -p "$PROFILE"
~/thrill/build/misc/standalone_profiler "$PROFILE/profile-${SLURM_NODEID}.json" &

echo "Starting Flink Master on $(hostname)"

if [ "$SLURM_PROCID" == 0 ]; then
    $FLINK_HOME/bin/taskmanager.sh start
    sync

    echo "Running application $@"
    "$@"

    $FLINK_HOME/bin/taskmanager.sh stop || true
    echo "Stopping Flink JobManager on $(hostname)"
    $FLINK_HOME/bin/jobmanager.sh stop cluster || true
    sync
    sleep 4s

    # signal srun to terminate the other tasks
    exit 1
else
    # launch Flink TaskManager
    $FLINK_HOME/bin/taskmanager.sh start
    PID_FILE=/tmp/flink-$USER-taskmanager.pid
    while ps -p `cat $PID_FILE` > /dev/null; do sleep 10m; done
    echo "Flink TaskManager stopped?"
fi
