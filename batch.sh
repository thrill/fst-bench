#!/bin/bash -x

set -e

TERASORT_RANGE=$(seq 30 36)

wc_prepare() {
    for scale in {20..37}; do
        SCALE=$scale ./workloads/wordcount/prepare/prepare.sh
    done
}

pr_prepare() {
    [ -z $RANGE ] && RANGE=$(seq 15 24)
    for scale in $RANGE; do
        SCALE=$scale ./workloads/pagerank/prepare/prepare.sh
    done
}

terasort_prepare() {
    [ -z $RANGE ] && RANGE=$(seq 30 36)
    for scale in $RANGE; do
        SCALE=$scale ./workloads/terasort/prepare/prepare.sh
    done
}

wc_spark() {
    [ -z $RANGE ] && RANGE=$(seq 20 35)
    for scale in $RANGE; do
        for run in {1..3}; do
            if [ $((scale % 2)) == 0 ]; then
                SCALE=$scale RUN=$run ./workloads/wordcount/spark/java/bin/run.sh
            else
                SCALE=$scale RUN=$run ./workloads/wordcount/spark/scala/bin/run.sh
            fi
        done
    done
}

wc_flink() {
    [ -z $RANGE ] && RANGE=$(seq 20 35)
    for scale in $RANGE; do
        for run in {1..3}; do
            if [ $((scale % 2)) == 0 ]; then
                SCALE=$scale RUN=$run ./workloads/wordcount/flink/java/bin/run.sh
            else
                SCALE=$scale RUN=$run ./workloads/wordcount/flink/scala/bin/run.sh
            fi
        done
    done
}

terasort_spark() {
    [ -z $RANGE ] && RANGE=$TERASORT_RANGE
    for scale in $RANGE; do
        for run in {1..3}; do
            SCALE=$scale RUN=$run ./workloads/terasort/spark/scala/bin/run.sh
        done
    done
}

terasort_flink() {
    [ -z $RANGE ] && RANGE=$TERASORT_RANGE
    for scale in $RANGE; do
        for run in {1..3}; do
            SCALE=$scale RUN=$run ./workloads/terasort/flink/scala/bin/run.sh
        done
    done
}

terasort_thrill() {
    [ -z $RANGE ] && RANGE=$TERASORT_RANGE
    for scale in $RANGE; do
        for run in {1..3}; do
            SCALE=$scale RUN=$run ./workloads/terasort/thrill/bin/run.sh
        done
    done
}

for p in $@; do
    $p
done
