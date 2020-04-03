#!/bin/bash

if [ $# != 1 ]; then
  echo "Usage: format_trans.sh <data-dir>"
  exit 1
fi

source=$1

grep 'hyp' $source > result.csv

sed -i 's/\*\*\*//g' result.csv

sed -i 's/hyp/,/g' result.csv

sed -i 's/ //g' result.csv

sed -i "1iid,words" result.csv