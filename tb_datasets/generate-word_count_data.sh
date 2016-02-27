#!/bin/bash -x
# generate word_count data

set -e

OUT=$WORK/HiBench/WordcountGen
RandomTextWriter=$HOME/thrill/build/examples/word_count/random_text_writer

# generate 256 small files containing random words

for p in {20..34}; do

    OUTP=$OUT/$p/Input

    rm -rvf $OUTP
    mkdir -p $OUTP

    for i in {1..256}; do
        $RandomTextWriter -s $((1234$i)) $((2 ** ($p - 8))) > ${OUTP}/input-$i.txt
    done
done
