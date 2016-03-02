#!/bin/bash -x

set -e

wc_prepare() {
    for scale in {20..37}; do
        SCALE=$scale ./workloads/wordcount/prepare/prepare.sh
    done
}

pr_prepare() {
    for scale in {21..25}; do
        SCALE=$scale ./workloads/pagerank/prepare/prepare.sh
    done
}

ts_prepare() {
    for scale in {31..36}; do
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

for p in $@; do
    $p
done
