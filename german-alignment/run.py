
import os
import sys
from collections import defaultdict
from textgrid import TextGrid, IntervalTier

def parse_ctm(ctm_path):
    file_dict = defaultdict(list)
    with open(ctm_path, 'r') as f:
        for line in f:
            line = line.strip()
            line = line.split(' ')
            filename = line[0]
            begin = float(line[2])
            duration = float(line[3])
            end = round(begin + duration, 2)
            label = line[4]
            file_dict[filename].append([begin, end, label])
    return file_dict

def find_max(input):
    return max(x[1] for x in input)

def ctm_to_textgrid(directory, out_directory):
    word_path = os.path.join(directory, 'word_ctm')
    if not os.path.exists(word_path):
        return
    phone_path = os.path.join(directory, 'phone_ctm')
    current = None
    word_dict = parse_ctm(word_path)
    phone_dict = parse_ctm(phone_path)
    num_files = len(word_dict)
    for i,(k,v) in enumerate(word_dict.items()):
        print('processing file {} of {}'.format(i,num_files))
        maxtime = find_max(v+phone_dict[k])
        tg = TextGrid(maxTime = maxtime)
        wordtier = IntervalTier(name = 'words', maxTime = maxtime)
        phonetier = IntervalTier(name = 'phones', maxTime = maxtime)
        for interval in v:
            wordtier.add(*interval)
        for interval in phone_dict[k]:
            phonetier.add(*interval)
        tg.append(wordtier)
        tg.append(phonetier)
        outpath = os.path.join(out_directory, k + '.TextGrid')
        tg.write(outpath)

if __name__ == '__main__':
    base_dir = os.path.expanduser('~/dev/kaldi-trunk/egs/gp/s5/exp/GE')
    output_dir = os.path.expanduser('~/Documents/Data/GlobalPhone/German/aln')
    for d in os.listdir(base_dir):
        print(d)
        in_dir = os.path.join(base_dir, d)
        out_dir = os.path.join(output_dir, d)
        if not os.path.exists(out_dir):
            os.mkdir(out_dir)
        ctm_to_textgrid(in_dir,out_dir)



