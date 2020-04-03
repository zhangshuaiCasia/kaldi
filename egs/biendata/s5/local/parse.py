# -*- coding=utf-8 -*-

import jieba

jieba.load_userdict('/home/zhangshuai/kaldi-master/egs/biendata/s5/data/local/dict/lexicon_parse.txt')

with open('/home/zhangshuai/kaldi-master/egs/biendata/s5/data/train_dev_sp/text_parse3','w') as w:
    with open('/home/zhangshuai/kaldi-master/egs/biendata/s5/data/train_dev_sp/text_raw','r') as r:
        for line in r.readlines():
            # print(line)
            id = line.split()[0]
            txt = line.split()[1:]
            seg = jieba.cut(''.join(txt),cut_all=False)
            # print(seg)
            w.write(id + ' ' + ' '.join(seg) + '\n')
        