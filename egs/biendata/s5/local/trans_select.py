# -*- coding=utf-8 -*-

import difflib

dev_text = []
with open('data/dev/text_noid','r') as dev:
    dev_text = dev.readlines()

num = 0
with open('data/resource/20181122_1_all.txt','r') as res, open('data/resource/selected_text','w') as sel:
    for line in res.readlines():
        i = 0
        # print(line)
        if len(line) > 7:
            for sentence in dev_text:
                # print(sentence)
                if i == 0:
                    if difflib.SequenceMatcher(None,sentence,line.replace(' ','')).ratio() > 0.6:
                        # print(line)
                        sel.write(''.join(line))
                        print(line)
                        i = i + 1
                        num = num + 1
                        print(num)