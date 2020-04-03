import json
import time
import sys
import os
import re
import pdb

def parse_time(time_str):
    t = time_str.strip().split('.', 1)
    time_struct = time.strptime(t[0], "%H:%M:%S")
    secs = time_struct.tm_hour * 3600. + time_struct.tm_min * 60. + time_struct.tm_sec
    if len(t) == 2:
        secs += float("0.{}".format(t[1]))
    elif len(t) != 1:
        raise ValueError("wrong format: {}".format(time_str))
    return secs

def parse_json(fn, uttdic, audio_dir, wavaffix):
    with open(fn, 'r', encoding="utf8") as f:
        print("Load {}".format(fn))
        l = json.load(f)
    cnt = 0
    for item in l:
        start_time = parse_time(item["start_time"]["original"])
        end_time = parse_time(item["end_time"]["original"])
        trans = item["words"].strip()
        spk = item["speaker"].strip()
        if not spk:
            spk = "UNK"
        session_id = item["session_id"].strip()
        utt_id = "{}_{:04d}".format(session_id, cnt)
        cnt += 1
        if utt_id in uttdic:
            raise ValueError("{} is in the dic. Something is wrong.".format(utt_id))
        if wavaffix:
            wavfn = "{}_{}.wav".format(session_id, wavaffix)
        else:
            wavfn = "{}.wav".format(session_id)
        uttdic[utt_id] = {
                "wav_path": os.path.join(audio_dir, wavfn),
                "text": trans,
                "spk": spk,
                "session_id": session_id,
                "start_time": start_time,
                "end_time": end_time
            }
    return uttdic

def format_wavscp(uttdic):
    l = []
    for key, item in uttdic.items():
        l.append(
            "{} {}".format(item["session_id"], item["wav_path"])
            )
    return "\n".join(l)

def format_text(uttdic):
    l = []
    for key, item in uttdic.items():
        txt = item["text"]
        if re.match("\[\S*\]", txt.strip()) is None:
            l.append(
                "{} {}".format(key, item["text"])
                )
    return "\n".join(l)

def format_utt2spk(uttdic):
    l = []
    for key, item in uttdic.items():
        l.append(
            "{} {}".format(key, item["spk"])
            )
    return "\n".join(l)

def format_segments(uttdic):
    l = []
    for key, item in uttdic.items():
        l.append(
            "{} {} {} {}".format(key, item["session_id"], item["start_time"], item["end_time"])
            )
    return "\n".join(l)


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage {}: <transdir> <audiodir> <affix> <destdir>".format(sys.argv[0]))
        sys.exit(0)

    trans_dir = sys.argv[1]
    audio_dir = sys.argv[2]
    wavaffix = sys.argv[3]
    datadir = sys.argv[4]
    uttdic = {}
    
    for fn in os.listdir(trans_dir):
        uttdic = parse_json(os.path.join(trans_dir, fn), uttdic, audio_dir, wavaffix)
    
    wavscp = format_wavscp(uttdic)
    text = format_text(uttdic)
    utt2spk = format_utt2spk(uttdic)
    segments = format_segments(uttdic)
    with open(os.path.join(datadir, "wav.scp"), "w") as f:
        f.write(wavscp)
    with open(os.path.join(datadir, "text"), "w") as f:
        f.write(text)
    with open(os.path.join(datadir, "utt2spk"), "w") as f:
        f.write(utt2spk)
    with open(os.path.join(datadir, "segments"), "w") as f:
        f.write(segments)
