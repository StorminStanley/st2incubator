#!/usr/bin/env bash

if [ $# -ne 1 ]
then
  echo "Usage: [$0] <number of words>" 1>&2
  exit 0
fi

function join { local IFS="$1"; shift; echo "$*"; }

# Constants
X=0
ALL_NON_RANDOM_WORDS=/usr/share/dict/words

# total number of non-random words available
non_random_words=`cat $ALL_NON_RANDOM_WORDS | wc -l`

HOSTNAME=()

# while loop to generate random words
# number of random generated words depends on supplied argument
while [ "$X" -lt "$1" ]; do
  random_number=`od -N3 -An -i /dev/urandom | awk -v f=0 -v r="$non_random_words" '{printf "%i", f + r * $1 / 16777216}'`
  host=$(sed `echo $random_number`"q;d" $ALL_NON_RANDOM_WORDS | tr '[:upper:]' '[:lower:]' | sed "s/'//")
  HOSTNAME[$[${#HOSTNAME[@]}+1]]=$host
  let "X = X + 1"
done

join - "${HOSTNAME[@]}" | tr -d '\n'
