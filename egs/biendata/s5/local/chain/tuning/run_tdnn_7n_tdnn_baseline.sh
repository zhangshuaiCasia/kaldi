#!/bin/bash


# 7n is a kind of factorized TDNN, with skip connections.  We have to write
# a proper description for this.  Note: I'm not happy with how

# The following compares this with our old tdnn_lstm system before kaldi 5.4
# (from run_tdnn_lstm_1m.sh), and with our old TDNN system.  It's over 1.5%
# absolute better than our old TDNN system, and even a bit better than our old
# TDNN+LSTM with dropout.
#
# local/chain/compare_wer_general.sh --rt03 tdnn_lstm_1m_ld5_sp tdnn_7m_sp tdnn7n_sp
# System                tdnn_lstm_1m_ld5_sp tdnn_7m_sp tdnn7n_sp
# WER on train_dev(tg)      12.33     13.70     12.18
# WER on train_dev(fg)      11.42     12.67     11.12
# WER on eval2000(tg)        15.2      16.6      14.9
# WER on eval2000(fg)        13.8      15.1      13.5
# WER on rt03(tg)            18.6      20.9      18.4
# WER on rt03(fg)            16.3      18.3      16.2
# Final train prob         -0.082    -0.085    -0.077
# Final valid prob         -0.099    -0.103    -0.093
# Final train prob (xent)        -0.959    -1.230    -0.994
# Final valid prob (xent)       -1.0305   -1.2704   -1.0194
# Num-parameters               39558436  16292693  20111396



# steps/info/chain_dir_info.pl exp_all/chain/tdnn7m23t_sp
# exp_all/chain/tdnn7m23t_sp: num-iters=394 nj=3..16 num-params=20.1M dim=40+100->6034 combine=-0.083->-0.081 (over 20) xent:train/valid[261,393,final]=(-1.05,-0.991,-0.994/-1.09,-1.02,-1.02) logprob:train/valid[261,393,final]=(-0.085,-0.077,-0.077/-0.100,-0.095,-0.093)
export CUDA_VISIBLE_DEVICES="0"
# nvidia-smi -c 3
set -e

# configs for 'chain'
stage=13
train_stage=0
get_egs_stage=-10
speed_perturb=false
affix=7n_tdnn_baseline
suffix=
$speed_perturb && suffix=_sp
if [ -e data_all/rt03 ]; then maybe_rt03=rt03; else maybe_rt03= ; fi

dir=exp_all/chain/tdnn_${affix}${suffix}
decode_iter=
decode_nj=10

# training options
frames_per_eg=150,110,100
remove_egs=false
common_egs_dir=
xent_regularize=0.1

test_online_decoding=false  # if true, it will run the last decoding stage.

# End configuration section.
echo "$0 $@"  # Print the command line for logging

. ./cmd.sh
. ./path.sh
. ./utils/parse_options.sh

if ! cuda-compiled; then
  cat <<EOF && exit 1
This script is intended to be used with GPUs but you have not compiled Kaldi with CUDA
If you want to use GPUs (and have them), go to src/, and configure and make on a machine
where "nvcc" is installed.
EOF
fi

# The iVector-extraction and feature-dumping parts are the same as the standard
# nnet3 setup, and you can skip them by setting "--stage 8" if you have already
# run those things.

train_set=train
ali_dir=exp_all/tri5a_ali
treedir=exp_all/chain/tri6_tree
lang=data_all/lang


# if we are using the speed-perturbed data_all we need to generate
# alignments for it.
# local/nnet3/run_ivector_common.sh --stage $stage \
  # --speed-perturb $speed_perturb \
  # --generate-alignments $speed_perturb || exit 1;


if [ $stage -le 9 ]; then
  # Get the alignments as lattices (gives the LF-MMI training more freedom).
  # use the same num-jobs as the alignments
  nj=$(cat exp_all/tri5a_ali/num_jobs) || exit 1;
  steps/align_fmllr_lats.sh --nj $nj --cmd "$train_cmd" data_all/$train_set \
    data_all/lang exp_all/tri5a exp_all/tri5a_lats
  rm exp_all/tri5a_lats/fsts.*.gz # save space
fi


if [ $stage -le 10 ]; then
  # Create a version of the lang/ directory that has one state per phone in the
  # topo file. [note, it really has two states.. the first one is only repeated
  # once, the second one has zero or more repeats.]
  # rm -rf $lang
  # cp -r data_all/lang $lang
  silphonelist=$(cat $lang/phones/silence.csl) || exit 1;
  nonsilphonelist=$(cat $lang/phones/nonsilence.csl) || exit 1;
  # Use our special topology... note that later on may have to tune this
  # topology.
  steps/nnet3/chain/gen_topo.py $nonsilphonelist $silphonelist >$lang/topo
fi

if [ $stage -le 11 ]; then
  # Build a tree using our new topology. This is the critically different
  # step compared with other recipes.
  steps/nnet3/chain/build_tree.sh --frame-subsampling-factor 3 \
      --context-opts "--context-width=2 --central-position=1" \
      --cmd "$train_cmd" 7000 data_all/$train_set $lang $ali_dir $treedir
fi

if [ $stage -le 12 ]; then
  echo "$0: creating neural net configs using the xconfig parser";

  num_targets=$(tree-info $treedir/tree |grep num-pdfs|awk '{print $2}')
  learning_rate_factor=$(echo "print (0.5/$xent_regularize)" | python)
  # opts="l2-regularize=0.002"
  # linear_opts="orthonormal-constraint=1.0"
  # output_opts="l2-regularize=0.0005 bottleneck-dim=512"

  mkdir -p $dir/configs

  cat <<EOF > $dir/configs/network.xconfig
  # input dim=100 name=ivector
  input dim=13 name=input

  # please note that it is important to have input layer with the name=input
  # as the layer immediately preceding the fixed-affine-layer to enable
  # the use of short notation for the descriptor
  # fixed-affine-layer name=lda input=Append(-1,0,1,ReplaceIndex(ivector, t, 0)) affine-transform-file=$dir/configs/lda.mat

  # the first splicing is moved before the lda layer, so no splicing here
  relu-batchnorm-layer name=tdnn1 $opts dim=512
  linear-component name=tdnn2l dim=512 $linear_opts input=Append(-3,0)
  relu-batchnorm-layer name=tdnn2 $opts input=Append(0,1) dim=512
  linear-component name=tdnn3l dim=512 $linear_opts
  relu-batchnorm-layer name=tdnn3 $opts dim=512
  linear-component name=tdnn4l dim=512 $linear_opts input=Append(-3,0)
  relu-batchnorm-layer name=tdnn4 $opts input=Append(0,1) dim=512
  linear-component name=tdnn5l dim=512 $linear_opts
  relu-batchnorm-layer name=tdnn5 $opts dim=512 input=Append(0,1)
  linear-component name=tdnn6l dim=512 $linear_opts input=Append(-3,0)
  relu-batchnorm-layer name=tdnn6 $opts input=Append(0,3) dim=512
  linear-component name=tdnn7l dim=512 $linear_opts input=Append(-3,0)
  relu-batchnorm-layer name=tdnn7 $opts input=Append(0,3) dim=512
  linear-component name=tdnn8l dim=512 $linear_opts input=Append(-3,0)
  relu-batchnorm-layer name=tdnn8 $opts input=Append(0,3) dim=512
  linear-component name=tdnn9l dim=512 $linear_opts input=Append(-3,0)
  relu-batchnorm-layer name=tdnn9 $opts input=Append(0,3) dim=512
  linear-component name=tdnn10l dim=512 $linear_opts input=Append(-3,0)
  relu-batchnorm-layer name=tdnn10 $opts input=Append(0,3) dim=512
  linear-component name=tdnn11l dim=512 $linear_opts input=Append(-3,0)
  relu-batchnorm-layer name=tdnn11 $opts input=Append(0,3) dim=512
  linear-component name=prefinal-l dim=512 $linear_opts

  relu-batchnorm-layer name=prefinal-chain input=prefinal-l $opts dim=512
  output-layer name=output include-log-softmax=false dim=$num_targets $output_opts

  relu-batchnorm-layer name=prefinal-xent input=prefinal-l $opts dim=512
  output-layer name=output-xent dim=$num_targets learning-rate-factor=$learning_rate_factor $output_opts


EOF
  steps/nnet3/xconfig_to_configs.py --xconfig-file $dir/configs/network.xconfig --config-dir $dir/configs/
fi

if [ $stage -le 13 ]; then
  if [[ $(hostname -f) == *.clsp.jhu.edu ]] && [ ! -d $dir/egs/storage ]; then
    utils/create_split_dir.pl \
     /export/b0{5,6,7,8}/$USER/kaldi-data_all/egs/swbd-$(date +'%m_%d_%H_%M')/s5c/$dir/egs/storage $dir/egs/storage
  fi
    # --feat.online-ivector-dir exp_all/nnet3/ivectors_${train_set} \
  steps/nnet3/chain/train.py --stage $train_stage \
    --cmd "$train_cmd" \
    --feat.cmvn-opts "--norm-means=true --norm-vars=true" \
    --chain.xent-regularize $xent_regularize \
    --chain.leaky-hmm-coefficient 0.1 \
    --chain.l2-regularize 0.0 \
    --chain.apply-deriv-weights false \
    --chain.lm-opts="--num-extra-lm-states=2000" \
    --egs.dir "$common_egs_dir" \
    --egs.stage $get_egs_stage \
    --egs.opts "--frames-overlap-per-eg 0" \
    --egs.chunk-width $frames_per_eg \
    --trainer.num-chunk-per-minibatch 64 \
    --trainer.frames-per-iter 1500000 \
    --trainer.num-epochs 4 \
    --trainer.optimization.num-jobs-initial 2 \
    --trainer.optimization.num-jobs-final 2 \
    --trainer.optimization.initial-effective-lrate 0.001 \
    --trainer.optimization.final-effective-lrate 0.0001 \
    --trainer.max-param-change 2.0 \
    --cleanup.remove-egs $remove_egs \
    --feat-dir data_all/${train_set} \
    --tree-dir $treedir \
    --lat-dir exp_all/tri5a_lats \
    --dir $dir  || exit 1;

fi

if [ $stage -le 14 ]; then
  # Note: it might appear that this $lang directory is mismatched, and it is as
  # far as the 'topo' is concerned, but this script doesn't read the 'topo' from
  # the lang directory.
  utils/mkgraph.sh --self-loop-scale 1.0 data_all/lang_test $dir $dir/graph_7n
fi


graph_dir=$dir/graph_7n
iter_opts=
if [ ! -z $decode_iter ]; then
  iter_opts=" --iter $decode_iter "
fi
if [ $stage -le 15 ]; then
  rm $dir/.error 2>/dev/null || true
          # --online-ivector-dir exp_all/nnet3/ivectors_${decode_set} \
  for decode_set in dev test; do
      (
      steps/nnet3/decode.sh --acwt 1.0 --post-decode-acwt 10.0 \
          --nj $decode_nj --cmd "$decode_cmd" $iter_opts \
          $graph_dir data_all/${decode_set} \
          $dir/decode_${decode_set}${decode_iter:+_$decode_iter}_sw1_tg || exit 1;
      if $has_fisher; then
          steps/lmrescore_const_arpa.sh --cmd "$decode_cmd" \
            data_all/lang_sw1_{tg,fsh_fg} data_all/${decode_set}_hires \
            $dir/decode_${decode_set}${decode_iter:+_$decode_iter}_sw1_{tg,fsh_fg} || exit 1;
      fi
      ) || touch $dir/.error &
  done
  wait
  if [ -f $dir/.error ]; then
    echo "$0: something went wrong in decoding"
    exit 1
  fi
fi

if $test_online_decoding && [ $stage -le 16 ]; then
  # note: if the features change (e.g. you add pitch features), you will have to
  # change the options of the following command line.
  steps/online/nnet3/prepare_online_decoding.sh \
       --mfcc-config conf/mfcc_hires.conf \
       $lang exp_all/nnet3/extractor $dir ${dir}_online

  rm $dir/.error 2>/dev/null || true
  for decode_set in train_dev eval2000 $maybe_rt03; do
    (
      # note: we just give it "$decode_set" as it only uses the wav.scp, the
      # feature type does not matter.

      steps/online/nnet3/decode.sh --nj $decode_nj --cmd "$decode_cmd" \
          --acwt 1.0 --post-decode-acwt 10.0 \
         $graph_dir data_all/${decode_set}_hires \
         ${dir}_online/decode_${decode_set}${decode_iter:+_$decode_iter}_sw1_tg || exit 1;
      if $has_fisher; then
          steps/lmrescore_const_arpa.sh --cmd "$decode_cmd" \
            data_all/lang_sw1_{tg,fsh_fg} data_all/${decode_set}_hires \
            ${dir}_online/decode_${decode_set}${decode_iter:+_$decode_iter}_sw1_{tg,fsh_fg} || exit 1;
      fi
    ) || touch $dir/.error &
  done
  wait
  if [ -f $dir/.error ]; then
    echo "$0: something went wrong in decoding"
    exit 1
  fi
fi


exit 0;
