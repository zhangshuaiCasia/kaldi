#!/data2/zhangshuai/anaconda3/bin
# -*- coding: utf-8 -*-

import os
import wave
from pydub import AudioSegment
import json

wav_path = "/home/zhangshuai/kaldi-master/egs/biendata/Magicdata/test"
trans_path = "/home/zhangshuai/kaldi-master/egs/biendata/Magicdata/test_no_ref_noise"
wav_segments_path = "/home/zhangshuai/kaldi-master/egs/biendata/Magicdata_seg/test"
trans_segments_path = "/home/zhangshuai/kaldi-master/egs/biendata/Magicdata_seg/test_trans"
wav_files = os.listdir(wav_path)
# wav_files = [wav_path + "/" + f for f in wav_files if f.endswith('.wav')]

trans_files = os.listdir(trans_path)
trans_files = [trans_path + "/" + f for f in trans_files if f.endswith('.json')]

for file in wav_files:
    if file[0] is not '.':
        # with wave.open(file, "rb") as wav_f:
        # print(f.getparams())
        wav_parts_paths = wav_segments_path + '/' + file.split('.', 1)[0]
        if not os.path.exists(wav_parts_paths):
            os.makedirs(wav_parts_paths)
        trans_parts_path = trans_segments_path + '/' + file.split('.', 1)[0]
        if not os.path.exists(trans_parts_path):
            os.makedirs(trans_parts_path)
        # print(wav_parts_paths)
        # print(file)
        print(trans_path + "/" + file.rsplit('_', 1)[0] + '.json')
        with open(trans_path + "/" + file.rsplit('_', 1)[0] + '.json', 'r') as trans_f:
            trans = json.load(trans_f)
            # print(len(trans))
            for i in range(len(trans)):
                # print(i)
                # sub_trans = trans[i]
                # if not lines:
                    # break
                # trans_info = lines.split('\t', 4)
                start_time = trans[i]['start_time']
                print(start_time)
                start_time = (int(start_time.split(':')[0])*3600 + int(start_time.split(':')[1])*60 + float(start_time.split(':')[2]))*1000
                end_time = trans[i]['end_time']
                print(end_time)
                # with open(trans_parts_path +  '/' + file.split('.', 1)[0] + '_' + str(i) + '.txt', 'w') as w:
                    # w.write(file.split('.', 1)[0] + '_' + str(i) + '.wav' + ' ' + trans[i]['words'])
                end_time = (int(end_time.split(':')[0])*3600 + int(end_time.split(':')[1])*60 + float(end_time.split(':')[2]))*1000
                # print(trans_info[0])
                # print(start_time,end_time)
                wav = AudioSegment.from_mp3(wav_path + '/' + file)

                wav_parts = wav[int(start_time) : int(end_time)]
                # wav_parts.export(wav_parts_paths + '/' + file.split('.', 1)[0] + '_' + str(i) + '.wav', format="wav")
                wav_parts.export(wav_parts_paths + '/' +  trans[i]['uttid'] + '.wav', format="wav")
            



#if __name__ == '__main__':
    