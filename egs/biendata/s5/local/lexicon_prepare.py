# -*- coding=utf-8 -*-

##筛选词
# with open('data/resource/lexicon.txt', 'r') as r, open('data/resource/lexicon_newlt2.txt', 'w') as w:
    # for line in r.readlines():
        # word = line.split()[0]
        # if len(word) < 2:
            # w.write(line)
    
lexic = []
with open('data/resource/lexicon.txt', 'r') as r_l:
    lexic = r_l.readlines()
    
with open('data/train_dev_sp/word_last', 'r') as r_w, open('data/resource/lexicon_last.txt', 'w') as w:
    for line in r_w.readlines():
        i = 0
        word = line.split()[0]
        for lex in lexic:
            if i == 0:
                if word == lex.split()[0]:
                    w.write(lex)
                    ++i
