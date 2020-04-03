#!/usr/bin/env python3
# -*- coding: utf-8 -*-

select_utt_file = '../exp_synthesis/chain/tdnn7q/decode_train/scoring_kaldi/wer_details/per_utt_select_0.8'

with open(select_utt_file,'r') as ur:
    select_utt = ur.readlines()
# print(select_utt)
with open('../exp_synthesis/chain/tdnn7q/decode_train/scoring_kaldi/wer_details/asr_synthesis/align_phones_0.8.txt','w') as aw:
    with open('../exp_synthesis/chain/tdnn7q/decode_train/scoring_kaldi/wer_details/asr_synthesis/align_phones.txt','r') as ar:
        for utt in ar.readlines():
            # print(utt)
            # print(utt.split()[0])
            if utt.split()[0] + '\n' in select_utt:
                # print(utt.split()[0])
                aw.write(utt)
