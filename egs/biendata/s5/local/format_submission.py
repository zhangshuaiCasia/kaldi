# encoding: utf8
import sys

def parse_res(fn):
    resdic = {}
    with open(fn, 'r') as f:
        for line in f:
            items = line.strip().split(' ', 1)
            if len(items) == 2:
                resdic[items[0]] = "".join(items[1].strip().split()) # rm spaces
            elif len(items) == 1:
                resdic[items[0]] = ""
            else:
                raise ValueError("Wrong format")
    return resdic

def parse_special(fn):
    spdic = {}
    with open(fn, 'r') as f:
        for line in f:
            items = line.strip().split(' ', 1)
            if len(items) == 2:
                spdic[items[0]] = items[1] # rm spaces
            else:
                raise ValueError("Wrong format")
    return spdic 

def load_utt(fn):
    with open(fn, 'r') as f:
        return f.read().strip().split("\n") 
        
if __name__ == "__main__":
    utts = load_utt(sys.argv[1])
    spdic = parse_special(sys.argv[2])
    resdic = parse_res(sys.argv[3])
    dest = sys.argv[4]
    final_res = "id,words\n"
    for utt in utts:
        if utt in spdic:
            words = spdic[utt]
        elif utt in resdic:
            words = resdic[utt]
        else:
            words = ""
        if not words:
            words = "嗯"
        final_res += "{},{}\n".format(utt, words)
    with open(dest, 'w') as f:
        f.write(final_res.strip())


















