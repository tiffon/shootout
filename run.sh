#!/bin/bash

# set -e

D8_BIN="d8"
CLEAN=false
SMALL=false
PERSIST_MSG="This file will not be deleted."
ONLY_KNUC=
ONLY_REV=
STATUS=0
REPEAT=1
IMPROVED_ONLY=


usage(){
  echo "Usage: ./run.sh [-hvcskr] [-8 <d8-path>]"
  echo "   Options:"
  echo "       -h    help           Print this message"
  echo "       -v    verbose        Print commands as they're executed"
  echo "       -c    clean          Delete the large input files when finished"
  echo "       -s    small          Do not run large tests"
  echo "       -k    knuc           Run only the knucleotide tests"
  echo "       -r    rev-comp       Run only the reverse-complement tests"
  echo "       -l    loop           Continuously run only the improved solutions"
  echo "       -i    improved       Run only the improved solution(s)"
  echo "       -8    v8             Path to v8 binary"
  echo
  echo "    Example: ./run.sh -c8 /usr/local/v8/out/native/d8"
  exit $STATUS
}


while getopts "hvcskrli8:" opt; do
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
    k)  ONLY_KNUC=true
        ;;
    r)  ONLY_REV=true
        ;;
    l)  REPEAT=99999
        echo "Repeating the timed runs forever."
        ;;
    i)  IMPROVED_ONLY=true
        echo "Only running the improved solution(s)."
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

echo

if [ -n "$ONLY_KNUC" ] && [ -n "$ONLY_REV" ]; then
    echo 'Invalid combination of options.'
    exit 1
fi

command -v $D8_BIN >/dev/null 2>&1 || {
    echo >&2 "V8 binary not found: '$D8_BIN'"
    echo >&2 "It must be available as the 'd8' command or specified via the '-8' option.";
    echo >&2 "For more information: https://code.google.com/p/v8/wiki/BuildingWithGYP";
    exit 1;
}

echo "Validate output from modified solution:"

if [ -n "$ONLY_REV" ]; then
    echo '    knucleotide:        skip'
else
    KNUC_DIFF=`node v8/knuc-joef.js < data/knucleotide-input.txt | diff data/knucleotide-output.txt -`
    if [ ! -z "$KNUC_DIFF" ]; then
        echo "v8/knuc-joef.js output fails against reference output."
        echo $KNUC_DIFF
        exit 1
    else
        echo '    knucleotide:        success'
    fi
fi

if [ -n "$ONLY_KNUC" ]; then
    echo '    reverse-complement: skip'
else
    REVCOMP_DIFF=`node v8/revcomp-joef.js < data/revcomp-input.txt | diff data/revcomp-output.txt -`
    if [ ! -z "$REVCOMP_DIFF" ]; then
        echo "v8/revcomp-joef.js output fails against reference output."
        echo $REVCOMP_DIFF
        exit 1
    else
        echo '    reverse-complement: success'
    fi
fi


if $SMALL ; then
    exit 0
fi
echo

if [ -z "$ONLY_REV" ] && [ ! -f data/knucleotide-input-500.txt ]; then
    echo "Creating a large knucleotide input file. $PERSIST_MSG"
    echo "    This may take a few minutes."
    $D8_BIN v8/multiply-input.js -- 500 < data/knucleotide-input.txt > data/knucleotide-input-500.txt
    echo "    data/knucleotide-input-500.txt"
    echo "    bytes: `stat -f "%z" data/knucleotide-input-500.txt`"
    echo
fi

if [ -z "$ONLY_KNUC" ] && [ ! -f data/revcomp-input-75k.txt ]; then
    echo "Creating a large reverse-complement input file. $PERSIST_MSG"
    echo "    This may take a few minutes."
    $D8_BIN v8/multiply-input.js -- 75000 < data/revcomp-input.txt > data/revcomp-input-75k.txt
    echo "    data/revcomp-input-75k.txt"
    echo "    bytes: `stat -f "%z" data/revcomp-input-75k.txt`"
    echo
fi

for i in `seq 1 $REPEAT`;
do

    if [ -z "$ONLY_REV" ]; then
        echo
        echo "KNUCLEOTIDE"
        echo "==========="

        echo
        echo "Improved script processing time:"
        time node v8/knuc-joef.js < data/knucleotide-input-500.txt > /dev/null

        if [ -z "$IMPROVED_ONLY" ]; then
            echo
            echo "Original script processing time:"
            time $D8_BIN v8/knuc-original.js < data/knucleotide-input-500.txt > /dev/null
        fi

        if $CLEAN ; then
            rm data/knucleotide-input-500.txt
        fi
    fi

    if [ -z "$ONLY_KNUC" ]; then
        echo
        echo
        echo "REVERSE-COMPLEMENT"
        echo "=================="

        echo
        echo "Improved script processing time:"
        time node v8/revcomp-joef.js < data/revcomp-input-75k.txt > /dev/null

        if [ -z "$IMPROVED_ONLY" ]; then
            echo
            echo "Original script processing time:"
            time $D8_BIN v8/revcomp-original.js < data/revcomp-input-75k.txt > /dev/null
        fi

        if $CLEAN ; then
            rm data/revcomp-input-75k.txt
        fi
    fi
done
