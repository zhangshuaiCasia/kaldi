#! /bin/bash

. ./path.sh || exit 1;

train_dir=data_synthesis/train
test_dir=data_synthesis/test
dev_dir=data_synthesis/dev

for dir in $train_dir $test_dir $dev_dir; do
	if [ ! -d $dir ]; then 
		mkdir $dir
	fi
done


shuf data_synthesis/utt2spk -o data_synthesis/utt2spk_shuf
row_num=`wc -l data_synthesis/utt2spk | awk '{print $1}'`
echo $row_num
train_num=$[row_num * 9 / 10]
echo $train_num

sed -n "1,${train_num}p"  data_synthesis/utt2spk_shuf > $train_dir/utt2spk
sed -n "$[${train_num} + 1],$[${row_num} * 95 / 100]p" data_synthesis/utt2spk_shuf > $test_dir/utt2spk
sed -n "$[${row_num} * 95 / 100 + 1],${row_num}p" data_synthesis/utt2spk_shuf > $dev_dir/utt2spk


for dir in  $dev_dir $test_dir $train_dir ; do
	n=1
	awk '{print $1}' $dir/utt2spk | while read line; do
		n=$((n+1))
        echo $dir, $line, $n 
        # set -x
		grep -w $line data_synthesis/text >> $dir/text
		grep -w $line data_synthesis/feats.scp >> $dir/feats.scp
        grep -w $line data_synthesis/spk2utt >> $dir/spk2utt
  	done
done 

# uniq  $test_dir/spk2utt
rm data_synthesis/utt2spk_shuf
