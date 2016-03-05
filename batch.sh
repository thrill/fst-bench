#!/bin/bash -x

set -e

WORDCOUNT_RANGE=$(seq 20 38)
TERASORT_RANGE=$(seq 30 36)
PAGERANK_RANGE=$(seq 15 24)

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

wordcount_spark() {
    [ -z $RANGE ] && RANGE=$WORDCOUNT_RANGE
    ./setup-ec2/spark-start.sh
    for scale in $RANGE; do
        for run in {1..3}; do
            if [ $((scale % 2)) == 0 ]; then
                SCALE=$scale RUN=$run ./workloads/wordcount/spark/java/bin/run.sh
            else
                SCALE=$scale RUN=$run ./workloads/wordcount/spark/scala/bin/run.sh
            fi
        done
    done
    ./setup-ec2/spark-stop.sh
}

wordcount_flink() {
    [ -z $RANGE ] && RANGE=$WORDCOUNT_RANGE
    ./setup-ec2/flink-start.sh
    for scale in $RANGE; do
        for run in {1..3}; do
            if [ $((scale % 2)) == 0 ]; then
                SCALE=$scale RUN=$run ./workloads/wordcount/flink/java/bin/run.sh
            else
                SCALE=$scale RUN=$run ./workloads/wordcount/flink/scala/bin/run.sh
            fi
        done
    done
    ./setup-ec2/spark-stop.sh
}

wordcount_thrill() {
    [ -z $RANGE ] && RANGE=$WORDCOUNT_RANGE
    for scale in $RANGE; do
        for run in {1..3}; do
            SCALE=$scale RUN=$run ./workloads/wordcount/thrill/bin/run.sh
        done
    done
}

################################################################################

pagerank_spark() {
    [ -z $RANGE ] && RANGE=$PAGERANK_RANGE
    for scale in $RANGE; do
        for run in {1..3}; do
            if [ $((scale % 2)) == 0 ]; then
                SCALE=$scale RUN=$run ./workloads/pagerank/spark/java/bin/run.sh
            else
                SCALE=$scale RUN=$run ./workloads/pagerank/spark/scala/bin/run.sh
            fi
        done
    done
}

pagerank_flink() {
    [ -z $RANGE ] && RANGE=$PAGERANK_RANGE
    for scale in $RANGE; do
        for run in {1..3}; do
            if [ $((scale % 2)) == 0 ]; then
                SCALE=$scale RUN=$run ./workloads/pagerank/flink/java/bin/run.sh
            else
                SCALE=$scale RUN=$run ./workloads/pagerank/flink/scala/bin/run.sh
            fi
        done
    done
}

pagerank_thrill() {
    [ -z $RANGE ] && RANGE=$PAGERANK_RANGE
    for scale in $RANGE; do
        for run in {1..3}; do
            SCALE=$scale RUN=$run ./workloads/pagerank/thrill/bin/run.sh
        done
    done
}

################################################################################

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
