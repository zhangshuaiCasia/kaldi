#!/bin/bash

# Copyright 2017 Xingyu Na
# Apache 2.0

# prepare dict resources

. ./path.sh

[ $# != 2 ] && echo "Usage: $0 <English-resource-path> <Chinese-resource-path>" && exit 1;

Eng_res_dir=$1
Chn_res_dir=$2

Eng_dict_dir=data_all/local/Eng_dict
Chn_dict_dir=data_all/local/Chn_dict
Combined_dict_dir=data_all/local/dict

mkdir -p $Eng_dict_dir
mkdir -p $Chn_dict_dir
mkdir -p $Combined_dict_dir

local/English_prepare_dict.sh $Eng_res_dir $Eng_dict_dir || exit 1;
echo "$0: English dict preparation succeeded"

local/Chinese_prepare_dict.sh $Chn_res_dir $Chn_dict_dir || exit 1;
echo "$0: Chinese dict preparation succeeded"

cat $Eng_dict_dir/lexicon.txt $Chn_dict_dir/dict_cn_common_word_iftone_20180823.txt > $Combined_dict_dir/lexicon.txt
cat $Eng_dict_dir/nonsilence_phones.txt $Chn_dict_dir/nonsilence_phones.txt > $Combined_dict_dir/nonsilence_phones.txt
cat $Eng_dict_dir/silence_phones.txt $Chn_dict_dir/silence_phones.txt > $Combined_dict_dir/silence_phones.txt
cat $Eng_dict_dir/optional_silence.txt $Chn_dict_dir/optional_silence.txt > $Combined_dict_dir/optional_silence.txt
cat $Eng_dict_dir/extra_questions.txt $Chn_dict_dir/extra_questions.txt > $Combined_dict_dir/extra_questions.txt

echo "$0: combined dict preparation succeeded"
exit 0;
