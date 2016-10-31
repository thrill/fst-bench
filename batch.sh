#!/bin/bash -x

set -e

WORDCOUNT_RANGE=$(seq 20 38)
WORDCOUNT_CC_RANGE=$(seq 20 38)
TERASORT_RANGE=$(seq 30 36)
PAGERANK_RANGE=$(seq 15 24)
KMEANS_RANGE=$(seq 24 28)
RUN_RANGE=$(seq 1 3)

RUN_SPARK=1
RUN_FLINK=1
RUN_THRILL=1
RUN_CLEANUP=1

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

kmeans_prepare() {
    [ -z $RANGE ] && RANGE=$KMEANS_RANGE

    ./setup-ec2/spark-stop.sh || true
    ./setup-ec2/spark-start.sh

    for scale in $RANGE; do
        SCALE=$scale ./workloads/kmeans/prepare/prepare.sh
    done

    ./setup-ec2/spark-stop.sh
}

# prepare for NEXT weak scaling step
prepare_scale() {
    s=$(log2hosts)
    s=$((s + 1))

    SCALE=$((35 + s)) ./workloads/wordcount/prepare/prepare.sh
    SCALE=$((22 + s)) ./workloads/pagerank/prepare/prepare.sh
    SCALE=$((34 + s)) ./workloads/terasort/prepare/prepare.sh

    ./setup-ec2/spark-stop.sh || true
    ./setup-ec2/spark-start.sh

    SCALE=$((24 + s)) ./workloads/kmeans/prepare/prepare.sh

    ./setup-ec2/spark-stop.sh
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
    h=$(cat ~/boxes.txt | wc -l)
    echo $(log2 $h)
}

################################################################################

wordcount_scale() {

    s=$(log2hosts)
    WEAKSCALE=$((35 + s))

    ./setup-ec2/spark-stop.sh || true
    ./setup-ec2/flink-stop.sh || true

    [ -e "/efs/HiBench/Wordcount/$WEAKSCALE" ] || \
        SCALE=$WEAKSCALE ./workloads/wordcount/prepare/prepare.sh

    if [ $RUN_SPARK != 0 ]; then
        ./setup-ec2/spark-start.sh

        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/wordcount/spark_java/bin/run.sh
            SCALE=$WEAKSCALE RUN=$run ./workloads/wordcount/spark_scala/bin/run.sh
        done

        ./setup-ec2/spark-stop.sh
    fi

    if [ $RUN_FLINK != 0 ]; then
        ./setup-ec2/flink-start.sh

        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/wordcount/flink_java/bin/run.sh
            SCALE=$WEAKSCALE RUN=$run ./workloads/wordcount/flink_scala/bin/run.sh
        done

        ./setup-ec2/flink-stop.sh
    fi

    if [ $RUN_THRILL != 0 ]; then
        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/wordcount/thrill/bin/run.sh
        done
    fi

    [ $RUN_CLEANUP != 0 ] && rm -rvf /efs/HiBench/Wordcount/$WEAKSCALE
}

################################################################################

wordcount_cc_scale() {

    s=$(log2hosts)
    WEAKSCALE=$((12 + s))

    ./setup-ec2/spark-stop.sh || true
    ./setup-ec2/flink-stop.sh || true

    [ -e "/efs/HiBench/WordcountCC/$WEAKSCALE" ] || \
        SCALE=$WEAKSCALE ./workloads/wordcount_cc/prepare/prepare.sh

    if [ $RUN_SPARK != 0 ]; then
        ./setup-ec2/spark-start.sh

        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/wordcount_cc/spark_java/bin/run.sh
            SCALE=$WEAKSCALE RUN=$run ./workloads/wordcount_cc/spark_scala/bin/run.sh
        done

        ./setup-ec2/spark-stop.sh
    fi

    if [ $RUN_FLINK != 0 ]; then
        ./setup-ec2/flink-start.sh

        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/wordcount_cc/flink_java/bin/run.sh
            SCALE=$WEAKSCALE RUN=$run ./workloads/wordcount_cc/flink_scala/bin/run.sh
        done

        ./setup-ec2/flink-stop.sh
    fi

    if [ $RUN_THRILL != 0 ]; then
        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/wordcount_cc/thrill/bin/run.sh
        done
    fi

    [ $RUN_CLEANUP != 0 ] && rm -rvf /efs/HiBench/WordcountCC/$WEAKSCALE
}

################################################################################

pagerank_scale() {

    s=$(log2hosts)
    WEAKSCALE=$((22 + s))

    ./setup-ec2/spark-stop.sh || true
    ./setup-ec2/flink-stop.sh || true

    [ -e "/efs/HiBench/Pagerank/$WEAKSCALE" ] || \
        SCALE=$WEAKSCALE ./workloads/pagerank/prepare/prepare.sh

    if [ $RUN_SPARK != 0 ]; then
        ./setup-ec2/spark-start.sh

        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE  RUN=$run ./workloads/pagerank/spark_java/bin/run.sh
            SCALE=$WEAKSCALE  RUN=$run ./workloads/pagerank/spark_scala/bin/run.sh
        done

        ./setup-ec2/spark-stop.sh
    fi

    if [ $RUN_FLINK != 0 ]; then
        ./setup-ec2/flink-start.sh

        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/pagerank/flink_java/bin/run.sh
            SCALE=$WEAKSCALE RUN=$run ./workloads/pagerank/flink_scala/bin/run.sh
        done

        ./setup-ec2/flink-stop.sh
    fi

    if [ $RUN_THRILL != 0 ]; then
        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/pagerank/thrill/bin/run.sh
        done
    fi

    [ $RUN_CLEANUP != 0 ] && rm -rvf /efs/HiBench/Pagerank/$WEAKSCALE
}

################################################################################

terasort_scale() {

    s=$(log2hosts)
    WEAKSCALE=$((34 + s))

    ./setup-ec2/spark-stop.sh || true
    ./setup-ec2/flink-stop.sh || true

    [ -e "/efs/HiBench/Terasort/$WEAKSCALE" ] || \
        SCALE=$WEAKSCALE ./workloads/terasort/prepare/prepare.sh

    if [ $RUN_SPARK != 0 ]; then
        ./setup-ec2/spark-start.sh

        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/terasort/spark_java/bin/run.sh
            # extremely slow
            #SCALE=$WEAKSCALE RUN=$run ./workloads/terasort/spark_scala/bin/run.sh
        done

        ./setup-ec2/spark-stop.sh
    fi

    if [ $RUN_FLINK != 0 ]; then
        ./setup-ec2/flink-start.sh

        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/terasort/flink_scala/bin/run.sh
        done

        ./setup-ec2/flink-stop.sh
    fi

    if [ $RUN_THRILL != 0 ]; then
        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/terasort/thrill/bin/run.sh
        done
    fi

    [ $RUN_CLEANUP != 0 ] && rm -rvf /efs/HiBench/Terasort/$WEAKSCALE
}

################################################################################

sleep_scale() {

    WEAKSCALE=60

    ./setup-ec2/spark-stop.sh || true
    ./setup-ec2/flink-stop.sh || true

    [ -e "/efs/HiBench/Sleep/$WEAKSCALE" ] || \
        SCALE=$WEAKSCALE ./workloads/sleep/prepare/prepare.sh

    if [ $RUN_SPARK != 0 ]; then
        ./setup-ec2/spark-start.sh

        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/sleep/spark_java/bin/run.sh
            SCALE=$WEAKSCALE RUN=$run ./workloads/sleep/spark_scala/bin/run.sh
        done

        ./setup-ec2/spark-stop.sh
    fi

    if [ $RUN_FLINK != 0 ]; then
        ./setup-ec2/flink-start.sh

        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/sleep/flink_java/bin/run.sh
            SCALE=$WEAKSCALE RUN=$run ./workloads/sleep/flink_scala/bin/run.sh
        done

        ./setup-ec2/flink-stop.sh
    fi

    if [ $RUN_THRILL != 0 ]; then
        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/sleep/thrill/bin/run.sh
        done
    fi

    [ $RUN_CLEANUP != 0 ] && rm -rvf /efs/HiBench/Sleep/$WEAKSCALE
}

################################################################################

kmeans_scale() {

    s=$(log2hosts)
    WEAKSCALE=$((24 + s))

    ./setup-ec2/spark-stop.sh || true
    ./setup-ec2/flink-stop.sh || true

    if [ $RUN_SPARK != 0 ]; then
        ./setup-ec2/spark-start.sh

        [ -e "/efs/HiBench/Kmeans/$WEAKSCALE" ] || \
            SCALE=$WEAKSCALE ./workloads/kmeans/prepare/prepare.sh

        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/kmeans/spark_java/bin/run.sh
            SCALE=$WEAKSCALE RUN=$run ./workloads/kmeans/spark_scala/bin/run.sh
        done

        ./setup-ec2/spark-stop.sh
    fi

    if [ $RUN_FLINK != 0 ]; then
        ./setup-ec2/flink-start.sh

        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/kmeans/flink_java/bin/run.sh
            SCALE=$WEAKSCALE RUN=$run ./workloads/kmeans/flink_scala/bin/run.sh
        done

        ./setup-ec2/flink-stop.sh
    fi

    if [ $RUN_THRILL != 0 ]; then
        for run in $RUN_RANGE; do
            SCALE=$WEAKSCALE RUN=$run ./workloads/kmeans/thrill/bin/run.sh
        done
    fi

    [ $RUN_CLEANUP != 0 ] && rm -rvf /efs/HiBench/Kmeans/$WEAKSCALE
}

################################################################################

all_scale() {
    wordcount_scale
    wordcount_cc_scale
    pagerank_scale
    terasort_scale
    sleep_scale
    kmeans_scale
}

################################################################################

for p in $@; do
    $p
done
