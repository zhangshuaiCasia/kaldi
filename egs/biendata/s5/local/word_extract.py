# -*- coding=utf-8 -*-

new_words = []

with open('/home/zhangshuai/kaldi-master/egs/biendata/s5/data/train_dev_sp/text_1st','r') as r:
    with open('/home/zhangshuai/kaldi-master/egs/biendata/s5/data/train_dev_sp/word_last','w') as w:
        for line in r.readlines():
            txt = line.split()[1:]
            new_words.extend(txt)
        words = set(new_words)
        for word in words:
            w.write(word + '\n')