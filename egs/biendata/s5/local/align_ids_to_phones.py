# 将对齐文件中的id序列转换为phone序列

ids_phones = {}

with open('/home/zhangshuai/kaldi-master/egs/code-switching/s5/data_all_phaseI/lang_test/words.txt', 'r') as p:
	lines = p.readlines()
	for line in lines:
		phone = line.split()[0]
		id = line.split()[1]
		ids_phones[id] = phone

align_phones = open('align_phones.txt','w')

with open('/home/zhangshuai/kaldi-master/egs/code-switching/s5/exp_all_phaseI/tri5a_ali/ali.1.txt','r') as a:
	lines = a.readlines()
	for line in lines:
		phones = []
		uttid = line.split()[0]
		ids = line.split()[1:]
		for id in ids:
			phones.append(ids_phones[id])
		align_phones.write(uttid + ' ' + ' '.join(phones) + '\n')


align_phones.close()