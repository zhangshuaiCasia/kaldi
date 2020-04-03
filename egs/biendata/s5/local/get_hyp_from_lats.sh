#!/bin/bash
. ./path.sh

word_ins_penalty=0.0,0.5,1.0
min_lmwt=8
max_lmwt=11

dir=$1
graphdir=$2
utts=$3
sp=$4
symtab=$graphdir/words.txt

if [ $# != 4 ]; then
    echo "$0: four params"
    exit 1;
fi

echo "Generate csv for submission.."

for wip in $(echo $word_ins_penalty | sed 's/,/ /g'); do
    mkdir -p $dir/hyps/penalty_$wip/log
    for LMWT in `seq $min_lmwt $max_lmwt`; do
    run.pl $dir/hyps/penalty_$wip/log/best_path.${LMWT}.log \
        lattice-scale --inv-acoustic-scale=${LMWT} "ark:gunzip -c $dir/lat.*.gz|" ark:- \| \
        lattice-add-penalty --word-ins-penalty=$wip ark:- ark:- \| \
        lattice-best-path --word-symbol-table=$symtab ark:- ark,t:- \| \
        utils/int2sym.pl -f 2- $symtab '>' $dir/hyps/penalty_$wip/${LMWT}.txt || exit 1;
    python local/format_submission.py $utts $sp $dir/hyps/penalty_$wip/${LMWT}.txt $dir/hyps/penalty_$wip/${LMWT}.csv
    done
done
