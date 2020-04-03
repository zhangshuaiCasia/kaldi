#!/bin/bash

# Copyright 2019 Zhang shuai
# Apache 2.0

#. ../path.sh || exit 1;


if [ $# != 2 ]; then
  echo "Usage: $0 <flac-path> <wav-path>"
  echo " $0 /seame/data/conversation/audio-falc /seame/data/conversation/audio-wav"
  exit 1;
fi

flac_dir=$1
wav_dir=$2
audios=`ls $flac_dir | awk -F '.' {'print $1'}`
for audio_name in $audios; do
	flac -d $flac_dir/${audio_name}".flac" -o $wav_dir/${audio_name}".wav"
done

echo "$0: flac to wav convert succeeded"
exit 0;
