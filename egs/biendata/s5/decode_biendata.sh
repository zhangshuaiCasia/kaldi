#!/bin/bash


. ./path.sh
. ./cmd.sh

data=../data/

stage=0

# 数据切分

if [ $stage -le 0 ]; then
	local/format_data.py $data/
fi



# 特征提取

if [ $stage -le 1 ]; then
	mfccdir=mfcc
    utils/fix_data_dir.sh data || exit 1;
	steps/make_mfcc.sh --cmd "$train_cmd" --nj 10 --mfcc-config conf/mfcc_hires.conf data exp/make_mfcc $mfccdir || exit 1;
	steps/compute_cmvn_stats.sh data exp/make_mfcc $mfccdir || exit 1;
	utils/fix_data_dir.sh data/$x || exit 1;
	
fi

# 解码

decode_nj=20
dir=exp/chain/tdnn7q
graph_dir=$dir/graph

if [ $stage -le 2 ]; then

    steps/nnet3/decode.sh --acwt 1.0 --post-decode-acwt 10.0 \
      --nj $decode_nj --cmd "$decode_cmd" \
      $graph_dir data \
      $dir/decode || exit 1;
  
fi


# 提交csv格式

if [ $stage -le 3 ]; then
	local/get_hyp_from_lats.sh 
fi






exit 0;
