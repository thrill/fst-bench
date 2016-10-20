#!/bin/bash

set -e

BASEURL=https://commoncrawl.s3.amazonaws.com

WETS=`curl $BASEURL/crawl-data/CC-MAIN-2016-40/wet.paths.gz | gunzip`

NARCHIVES=$1
OUTBASE=$2

echo "cc_download.sh: fetching $NARCHIVES archives into $OUTBASE"

( for WET in $WETS; do
    OUTFILE="$WET"
    # strip off /crawl-data/
    OUTFILE=${OUTFILE##crawl-data/}
    # convert / to _
    OUTFILE=${OUTFILE//\//_}
    # prepend OUTBASE
    OUTFILE="$OUTBASE$OUTFILE"

    echo "$BASEURL/$WET -> $OUTFILE" 1>&2
    echo wget -c "$BASEURL/$WET" -O "$OUTFILE"

    NARCHIVES=$((NARCHIVES - 1))
    [ $NARCHIVES == 0 ] && break
done ) | parallel
