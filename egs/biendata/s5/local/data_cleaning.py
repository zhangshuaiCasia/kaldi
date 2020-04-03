# -*- coding: utf-8 -*-

import re

# resource_dir = "data_text_clean/test/text"
# target_dir = "data_text_clean/test/text_new"
# # remove illegal encode whiteblanks
# with open(resource_dir, 'r') as f:
	# for line in f.readlines():
		# new = re.sub('\u3000',' ',line)
		# with open(target_dir, 'a') as w:
			# w.write(new)






## remove (ppl,ppo,ppc..), 	
# resource_dir = "data/text"
# target_dir = "data_text_clean/text"
# pp = ['(ppl)', '(ppo)', '(ppc)', '(ppb)']
# utt_id = []
# with open(resource_dir, 'r') as f:
	# for line in f.readlines():
		# l = line.split()
		# if len(l) == 2 and l[1] in  pp:
			# utt_id.append(l[0])	
			# continue
		# with open(target_dir, 'a') as w:
			# w.write(line)	
# print(utt_id)
# for file in ['utt2spk', 'spk2utt', 'wav.scp']:
	# with open('data/' + file, 'r') as f:
		# for line in f.readlines():
			# l = line.split()
			# if l[0] in utt_id:
				# continue
			# with open('data_text_clean/' + file, 'a') as w:
				# w.write(line)	

## remove [],()
# resource_dir = "data_all_phaseI/text"
# target_dir = "data_all_phaseI/text1"
# # symble = ['(', ')', '[', ']', '*']
# with open(resource_dir, 'r') as f:
	# for line in f.readlines():		
		# new = line.replace('(ppl)','').replace('(ppo)','').replace('(ppc)','').replace('(ppb)','') \
			# .replace('(','').replace(')','').replace(']','').replace('[','').replace('*','') \
			# .replace('【','').replace('】','').replace('.','').replace('-','').replace('~','') \
			# .replace('（','').replace('）','').replace('［','').replace('］','')
		# with open(target_dir, 'a') as w:
			# w.write(new)	

## remove blank lines, 	
# resource_dir = "data_text_clean/text1"
# target_dir = "data_text_clean/text2"

# utt_id = []
# with open(resource_dir, 'r') as f:
	# for line in f.readlines():
		# l = line.split()
		# if len(l) == 1:
			# utt_id.append(l[0])	
			# continue
		# with open(target_dir, 'a') as w:
			# w.write(line)	
# print(utt_id)
# for file in ['utt2spk', 'spk2utt', 'wav.scp']:
	# with open('data_text_clean/' + file, 'r') as f:
		# for line in f.readlines():
			# l = line.split()
			# if l[0] in utt_id:
				# continue
			# with open('data_text_clean/' + file + '_2', 'a') as w:
				# w.write(line)	

## parse words to word
# resource_dir = "data_all/text"
# target_dir = "data_all/text1"

# utt_id = []
# with open(resource_dir, 'r') as f:
	# for line in f.readlines():
		# l = line.split()
		# for li in l:
			# if li >= u'\u4e00' and li <= u'\u9fa5' and len(li) >  1:				
				# line = line.replace(li, " ".join([i for i in li]))
		# with open(target_dir, 'a') as w:
				# w.write(line)	
				
#中英文分词
resource_dir = "/home/zhangshuai/kaldi-master/egs/biendata/s5/data/train_dev_sp/text_raw"
target_dir = "/home/zhangshuai/kaldi-master/egs/biendata/s5/data/train_dev_sp/text_char"


en = ''
with open(resource_dir, 'r') as f:
	for line in f.readlines():
		utt_id = []
		line_list = line.split()
		l = line_list[1:]
		for li in l:
			for i in range(len(li)):
				if i+1 <= len(li): 
					if (li[i] < u'\u4e00' or li[i] > u'\u9fa5'):
						en = en + li[i]
						if i+1 == len(li):
							utt_id.append(en)
							en = ''
						elif (li[i+1] >= u'\u4e00' and li[i+1] <= u'\u9fa5'):
							utt_id.append(en)
							en = ''	
					else:
						utt_id.append(li[i])
		with open(target_dir, 'a') as w:
			
			w.write(line_list[0] + ' ' + " ".join(utt_id) + '\n')


## 删除中文，余下英文用于生成wordpiece

# resource_dir = "data_all_phaseI/text_raw"
# target_dir = "data_all_phaseI/text1"


# en = ''
# with open(resource_dir, 'r') as f:
	# for line in f.readlines():
		# utt_id = []
		# line_list = line.split()
		# l = line_list[1:]
		# for li in l:
			# for i in range(len(li)):
				# if i+1 <= len(li): 
					# if (li[i] < u'\u4e00' or li[i] > u'\u9fa5'):
						# en = en + li[i]
						# if i+1 == len(li):
							# utt_id.append(en)
							# en = ''
						# elif (li[i+1] >= u'\u4e00' and li[i+1] <= u'\u9fa5'):
							# utt_id.append(en)
							# en = ''	
					# else:
						# utt_id.append(li[i])
		# with open(target_dir, 'a') as w:
			
			# w.write(line_list[0] + ' ' + " ".join(utt_id) + '\n')

## 将文本中非语音发音替换为<SPOKEN_NOISE>

# resource_dir = "data_all/text_raw"
# target_dir = "data_all/text1"
# # symble = ['(', ')', '[', ']', '*']
# with open(resource_dir, 'r') as f:
	# for line in f.readlines():
		# uttid = line.split()[0]
		# new = line.replace('(ppl)','<SPOKEN_NOISE>').replace('(ppo)','<SPOKEN_NOISE>').replace('(ppc)','<SPOKEN_NOISE>').replace('(ppb)','<SPOKEN_NOISE>') \
			# .replace('(','').replace(')','').replace(']','').replace('[','').replace('*','') \
			# .replace('【','').replace('】','').replace('.','').replace('～','') \
			# .replace('（','').replace('）','').replace('［','').replace('］','')
		# with open(target_dir, 'a') as w:
			# w.write(uttid + ' ' + new.lower())	





