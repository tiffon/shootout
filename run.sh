#!/bin/bash

set -e

D8_BIN="d8"
CLEAN=false
SMALL=false
PERSIST_MSG="This file will not be deleted."
STATUS=0


usage(){
  echo "Usage: ./run.sh [-hvcs] [-8 <d8-path>]"
  echo "   Options:"
  echo "       h    help       Print this message"
  echo "       v    verbose    Print commands as they're executed"
  echo "       c    clean      Delete the large input files when finished"
  echo "       s    small      Do not run large tests"
  echo "       8    v8         Path to v8 binary"
  echo
  echo "    Example: ./run.sh -c8 /usr/local/v8/out/native/d8"
  exit $STATUS
}


while getopts "hvcs8:" opt; do
    case "$opt" in
    h)  usage
        ;;
    v)  set -x
        ;;
    c)  CLEAN=true
        PERSIST_MSG=""
        ;;
    s)  SMALL=true
        ;;
    8)  D8_BIN=$OPTARG
        ;;
    \?) STATUS=1
        usage
        ;;
    esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift


command -v $D8_BIN >/dev/null 2>&1 || {
    echo >&2 "V8 binary not found: '$D8_BIN'"
    echo >&2 "It must be available as the 'd8' command or specified via the '-8' option.";
    echo >&2 "For more information: https://code.google.com/p/v8/wiki/BuildingWithGYP";
    exit 1;
}

KNUC_DIFF=`$D8_BIN v8/knuc-joef.js < data/knucleotide-input.txt | diff data/knucleotide-output.txt -`

if [ ! -z "$KNUC_DIFF" ]; then
    echo "v8/knuc-joef.js output fails against reference output."
    exit 1
fi

REVCOMP_DIFF=`$D8_BIN v8/revcomp-joef.js < data/revcomp-input.txt | diff data/revcomp-output.txt -`

if [ ! -z "$REVCOMP_DIFF" ]; then
    echo "v8/revcomp-joef.js output fails against reference output."
    exit 1
fi

if $SMALL ; then
    echo "There are no discrepancies between the reference output and the output from the modified solutions."
    exit 0
fi

if [ ! -f data/knucleotide-input-500.txt ]; then
    echo "Creating a large knucleotide input file. $PERSIST_MSG"
    echo "    This may take a few minutes."
    $D8_BIN v8/multiply-input.js -- 500 < data/knucleotide-input.txt > data/knucleotide-input-500.txt 
    echo "    data/knucleotide-input-500.txt"
    echo "    bytes: `stat -f "%z" data/knucleotide-input-500.txt`"
    echo
fi

if [ ! -f data/revcomp-input-75k.txt ]; then
    echo "Creating a large reverse-complement input file. $PERSIST_MSG"
    echo "    This may take a few minutes."
    $D8_BIN v8/multiply-input.js -- 75000 < data/revcomp-input.txt > data/revcomp-input-75k.txt 
    echo "    data/revcomp-input-75k.txt"
    echo "    bytes: `stat -f "%z" data/revcomp-input-75k.txt`"
    echo
fi

echo
echo "KNUCLEOTIDE"
echo "==========="

echo
echo "Improved script processing time:"
time $D8_BIN v8/knuc-joef.js < data/knucleotide-input-500.txt > /dev/null

echo
echo "Original script processing time:"
time $D8_BIN v8/knuc-original.js < data/knucleotide-input-500.txt > /dev/null

echo
echo
echo "REVERSE-COMPLEMENT"
echo "=================="

echo
echo "Improved script processing time:"
time $D8_BIN v8/revcomp-joef.js < data/revcomp-input-75k.txt > /dev/null


echo
echo "Original script processing time:"
time $D8_BIN v8/revcomp-original.js < data/revcomp-input-75k.txt > /dev/null

if $CLEAN ; then
    rm data/knucleotide-input-500.txt
    rm data/revcomp-input-75k.txt
fi
