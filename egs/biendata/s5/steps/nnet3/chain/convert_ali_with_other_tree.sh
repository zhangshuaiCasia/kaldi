#!/bin/bash
# Copyright 2012-2015  Johns Hopkins University (Author: Daniel Povey).
#  Apache 2.0.


# This script builds a tree for use in the 'chain' systems (although the script
# itself is pretty generic and doesn't use any 'chain' binaries).  This is just
# like the first stages of a standard system, like 'train_sat.sh', except it
# does 'convert-ali' to convert alignments to a monophone topology just created
# from the 'lang' directory (in case the topology is different from where you
# got the system's alignments from), and it stops after the tree-building and
# model-initialization stage, without re-estimating the Gaussians or training
# the transitions.


# Begin configuration section.
stage=-5
exit_stage=-100 # you can use this to require it to exit at the
                # beginning of a specific stage.  Not all values are
                # supported.
cmd=run.pl
frame_subsampling_factor=1
leftmost_questions_truncate=-1  # note: this option is deprecated and has no effect
repeat_frames=false
# End configuration section.

echo "$0 $@"  # Print the command line for logging

[ -f path.sh ] && . ./path.sh
. parse_options.sh || exit 1;

if [ $# != 4 ]; then
  echo "Usage: $0 <data> <lang> <ali-dir> <exp-dir>"
  echo " e.g.: $0 --frame-subsampling-factor 3 \\"
  echo "   --context-opts '--context-width=2 --central-position=1'  \\"
  echo "    3500 data/train_si84 data/lang_chain exp/tri3b_ali_si284_sp exp/chain/tree_a_sp"
  echo "Main options (for others, see top of script file)"
  echo "  --cmd (utils/run.pl|utils/queue.pl <queue opts>) # how to run jobs."
  echo "  --config <config-file>                           # config containing options"
  echo "  --stage <stage>                                  # stage to do partial re-run from."
  echo "  --repeat-frames <true|false>                     # Only affects alignment conversion at"
  echo "                                                   # the end. If true, generate an "
  echo "                                                   # alignment using the frame-subsampled "
  echo "                                                   # topology that is repeated "
  echo "                                                   # --frame-subsampling-factor times "
  echo "                                                   # and interleaved, to be the same "
  echo "                                                   # length as the original alignment "
  echo "                                                   # (useful for cross-entropy training "
  echo "                                                   # of reduced frame rate systems)."
  echo "  --context-opts <option-string>                   # Options controlling phonetic context;"
  echo "                                                   # we suggest '--context-width=2 --central-position=1',"
  echo "                                                   # which is left bigram."
  echo "  --frame-subsampling-factor <factor>              # Factor (e.g. 3) controlling frame subsampling"
  echo "                                                   # at the neural net output, so the frame rate at"
  echo "                                                   # the output is less than at the input."
  exit 1;
fi

data=$1
alidir=$2
dir=$3
lang=$4

utils/lang/check_phones_compatible.sh $lang/phones.txt $alidir/phones.txt || exit 1;

for f in $alidir/final.mdl $alidir/ali.1.gz $dir/final.mdl $dir/tree; do
  [ ! -f $f ] && echo "train_sat.sh: no such file $f" && exit 1;
done

nj=`cat $alidir/num_jobs` || exit 1;

mkdir -p $dir

echo $nj >$dir/num_jobs

if [ $stage -le -1 ]; then
  # Convert the alignments to the new tree.  Note: we likely will not use these
  # converted alignments in the CTC system directly, but they could be useful
  # for other purposes.
  echo "$0: Converting alignments from $alidir to use current tree"
  $cmd JOB=1:$nj $dir/log/convert.JOB.log \
    convert-ali --repeat-frames=$repeat_frames \
      --frame-subsampling-factor=$frame_subsampling_factor \
      $alidir/final.mdl $dir/final.mdl $dir/tree \
      "ark:gunzip -c $alidir/ali.JOB.gz|" "ark:|gzip -c >$dir/ali.JOB.gz" || exit 1;
fi

echo $0: Done converting alignments
