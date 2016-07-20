#!/bin/bash -x

set -e

WORDCOUNT_RANGE=$(seq 20 38)
TERASORT_RANGE=$(seq 30 36)
PAGERANK_RANGE=$(seq 15 24)
RUN_RANGE=$(seq 1 1)

RUN_SPARK=("$HOME/thrill/run/slurm/invoke.sh" "setup-slurm/run-spark.sh")
RUN_FLINK=("$HOME/thrill/run/slurm/invoke.sh" "setup-slurm/run-flink.sh")

wordcount_prepare() {
    [ -z $RANGE ] && RANGE=$WORDCOUNT_RANGE
    for scale in $RANGE; do
        SCALE=$scale ./workloads/wordcount/prepare/prepare.sh
    done
}

pagerank_prepare() {
    [ -z $RANGE ] && RANGE=$PAGERANK_RANGE
    for scale in $RANGE; do
        SCALE=$scale ./workloads/pagerank/prepare/prepare.sh
    done
}

terasort_prepare() {
    [ -z $RANGE ] && RANGE=$TERASORT_RANGE
    for scale in $RANGE; do
        SCALE=$scale ./workloads/terasort/prepare/prepare.sh
    done
}

################################################################################

function log2 {
    local x=0
    for ((y=$1 - 1; $y > 0; y >>= 1)); do
        let x=$x+1
    done
    echo $x
}

function log2hosts {
    echo $(log2 $SLURM_NNODES)
}

################################################################################

wordcount_scale() {

    s=$(log2hosts)
    WEAKSCALE=$((35 + s))
    export BENCHMARK=wordcount

    SCALE=$WEAKSCALE ./workloads/wordcount/prepare/prepare.sh

    set +e

    for run in $RUN_RANGE; do
        SCALE=$WEAKSCALE RUN=$run ${RUN_SPARK[@]} \
             ./workloads/wordcount/spark_scala/bin/run.sh
        SCALE=$WEAKSCALE RUN=$run ${RUN_SPARK[@]} \
             ./workloads/wordcount/spark_java/bin/run.sh
    done

    for run in $RUN_RANGE; do
        SCALE=$WEAKSCALE RUN=$run ${RUN_FLINK[@]} \
             ./workloads/wordcount/flink_scala/bin/run.sh
        SCALE=$WEAKSCALE RUN=$run ${RUN_FLINK[@]} \
             ./workloads/wordcount/flink_java/bin/run.sh
    done

    for run in $RUN_RANGE; do
        SCALE=$WEAKSCALE RUN=$run \
             ./workloads/wordcount/thrill/bin/run.sh
    done

    set -e

    rm -rvf $WORK/HiBench/Wordcount/$SCALE
}

################################################################################

pagerank_scale() {

    s=$(log2hosts)
    WEAKSCALE=$((22 + s))
    export BENCHMARK=pagerank

    SCALE=$WEAKSCALE ./workloads/pagerank/prepare/prepare.sh

    set +e

    for run in $RUN_RANGE; do
        SCALE=$WEAKSCALE RUN=$run ${RUN_SPARK[@]} \
             ./workloads/pagerank/spark_scala/bin/run.sh
        SCALE=$WEAKSCALE RUN=$run ${RUN_SPARK[@]} \
             ./workloads/pagerank/spark_java/bin/run.sh
    done

    for run in $RUN_RANGE; do
        SCALE=$WEAKSCALE RUN=$run ${RUN_FLINK[@]} \
             ./workloads/pagerank/flink_scala/bin/run.sh
        SCALE=$WEAKSCALE RUN=$run ${RUN_FLINK[@]} \
             ./workloads/pagerank/flink_java/bin/run.sh
    done

    for run in $RUN_RANGE; do
        SCALE=$WEAKSCALE RUN=$run \
             ./workloads/pagerank/thrill/bin/run.sh
    done

    set -e

    rm -rvf $WORK/HiBench/Pagerank/$SCALE
}

################################################################################

terasort_scale() {

    s=$(log2hosts)
    WEAKSCALE=$((34 + s))
    export BENCHMARK=terasort

    SCALE=$WEAKSCALE ./workloads/terasort/prepare/prepare.sh

    set +e

    for run in $RUN_RANGE; do
        SCALE=$WEAKSCALE RUN=$run ${RUN_SPARK[@]} \
             ./workloads/terasort/spark_java/bin/run.sh
        SCALE=$WEAKSCALE RUN=$run ${RUN_SPARK[@]} \
             ./workloads/terasort/spark_scala/bin/run.sh
    done

    for run in $RUN_RANGE; do
        SCALE=$WEAKSCALE RUN=$run ${RUN_FLINK[@]} \
             ./workloads/terasort/flink_scala/bin/run.sh
    done

    for run in $RUN_RANGE; do
        SCALE=$WEAKSCALE RUN=$run \
             ./workloads/terasort/thrill/bin/run.sh
    done

    set -e

    rm -rvf $WORK/HiBench/Terasort/$SCALE
}

################################################################################

kmeans_scale() {

    s=$(log2hosts)
    WEAKSCALE=$((24 + s))
    export BENCHMARK=kmeans

    SCALE=$WEAKSCALE ./workloads/kmeans/prepare/prepare.sh

    set +e

    for run in $RUN_RANGE; do
        SCALE=$WEAKSCALE RUN=$run ${RUN_SPARK[@]} \
             ./workloads/kmeans/spark_java/bin/run.sh
        SCALE=$WEAKSCALE RUN=$run ${RUN_SPARK[@]} \
             ./workloads/kmeans/spark_scala/bin/run.sh
    done

    for run in $RUN_RANGE; do
        SCALE=$WEAKSCALE RUN=$run \
             ./workloads/kmeans/thrill/bin/run.sh
    done

    set -e

    rm -rvf $WORK/HiBench/Kmeans/$SCALE
}

################################################################################

all_scale() {
    wordcount_scale
    pagerank_scale
    terasort_scale
    kmeans_scale
}

################################################################################

for p in $@; do
    $p
done

################################################################################
