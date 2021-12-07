__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from collections import defaultdict
from json import load, dump
from math import log
from os import listdir
from os.path import isfile, join

import matplotlib.pyplot as plt
from wordcloud import WordCloud

from config_handler import ConfigHandler


class DocSummarizer(object):

    def __init__(self, config):
        # self.summ_path = 'data/txt'
        # self.imag_path = 'data/images'
        # self.summ_pcnt = 0.2
        self.summ_path = config.get_config_option('content', 'summ_path')
        self.imag_path = config.get_config_option('content', 'imag_path')
        self.summ_pcnt = config.get_eval_option('summary', 'summ_pcnt')
        self.ASIS = config.get_eval_option('gather', 'as_is')

    def compute_tf_idf(self, number, aent_dict, apos_dict, adoc_dict):
        for c, e in aent_dict.items():
            e['df'] = len(e['df'])
            idf = log(float(number)/float(e['df']))
            e['idf'] = idf
            for _, doc_dict in adoc_dict.items():
                if c in doc_dict['ent']:
                    tf = doc_dict['ent'][c]['tf']
                    doc_dict['ent'][c]['tf_idf'] = (1.0 + log(tf)) * idf

        for c, p in apos_dict.items():
            p['df'] = len(p['df'])
            idf = log(float(number)/float(p['df']))
            p['idf'] = idf
            for _, doc_dict in adoc_dict.items():
                if c in doc_dict['pos']:
                    tf = doc_dict['pos'][c]['tf']
                    doc_dict['pos'][c]['tf_idf'] = (1.0 + log(tf)) * idf

        for _, doc_dict in adoc_dict.items():
            for sen in doc_dict['sen']:
                score = 0.0
                score += sum([doc_dict['ent'][c]['tf_idf'] for c in sen['e']])
                score += sum([doc_dict['pos'][c]['tf_idf'] for c in sen['p']])
                sen['s'] = score

        self.aent_dict = aent_dict
        self.apos_dict = apos_dict
        self.adoc_dict = adoc_dict
        # self.print_stats()

    def print_stats(self):
        for doc_id, doc_dict in self.adoc_dict.items():
            print('---------- %s ---------- ' % doc_id)
            for sen in doc_dict['sen']:
                print(sen)
            for c in sorted(doc_dict['ent'].keys()):
                print(c, doc_dict['ent'][c])
            for c in sorted(doc_dict['pos'].keys()):
                print(c, doc_dict['pos'][c])

        print('---------- All NERs ---------- ')
        for c in sorted(self.aent_dict.keys()):
            print(c, self.aent_dict[c])

        print('---------- All POSs ---------- ')
        for c in sorted(self.apos_dict.keys()):
            print(c, self.apos_dict[c])

    def generate_wordcloud(self, doc_id, doc_dict):
        cloud = WordCloud( width=1600, height=1200)
        freq_dict = dict()
        for t in ['ent', 'pos']:
            max_e = max(e['tf_idf'] for  e in doc_dict[t].values())
            if max_e > 0.0:
                freq_dict.update({ c: e['tf_idf'] for c, e in doc_dict[t].items() })
            else:
                freq_dict.update({ c: e['tf'] for c, e in doc_dict[t].items() })
        cloud.generate_from_frequencies(freq_dict)
        image_file = '%s/%s.png' % (self.imag_path, doc_id) 
        cloud.to_file(image_file)

    def generate_summary(self, doc_id, doc_dict):

        with open(join(self.summ_path, doc_id + '.txt'), 'wt') as ofile:
            for header in self.ASIS:
                ofile.write(f"{header.capitalize()}\n")
                ofile.write("---------------------------------------------------------\n")
                # k_max = max([len(k)+1 for k in doc_dict[header].keys()])
                # v_max = max([len(v)+1 for v in doc_dict[header].values()])
                for k, v in doc_dict[header].items():
                    # ofile.write(f"({k:{k_max}})\t{v:{v_max}}\n")
                    ofile.write(f"{k:20} {v}\n")
                ofile.write("\n")

            ofile.write(f"Summary (top {self.summ_pcnt:.2%})\n")
            ofile.write("---------------------------------------------------------\n")
            scores = { i: doc_dict['sen'][i]['s'] for i in range(0, len(doc_dict['sen'])) }
            scores = list(sorted(scores.values(), reverse = True))[:int(self.summ_pcnt * len(doc_dict['sen']))]
            for sen in doc_dict['sen']:
                if sen['s'] in scores:
                    ofile.write(f"({sen['s']:>7.3f}) {sen['t'].strip()}\n")
            
            for t in ['ent', 'pos']:
                k_type = 'Key Phrases' if t == 'pos' else 'Named Entities'
                ofile.write(f"\n{k_type} (text, score, freq, docs) (top {self.summ_pcnt:.2%})\n")
                ofile.write("---------------------------------------------------------\n")
                p_max = int(self.summ_pcnt * len(doc_dict[t]))
                l_max = max([len(c) for c in doc_dict[t]]) + 1
                scores = { c: e['tf_idf'] for c, e in doc_dict[t].items() }
                count, done = 1, False
                for c, tf_idf in sorted(scores.items(), key=lambda item: item[1], reverse = True):
                    tf = doc_dict[t][c]['tf']
                    df = self.aent_dict[c]['df'] if t == 'ent' else self.apos_dict[c]['df']
                    sc = c.replace('\n', ' ')
                    if count >= p_max and not done:
                        ofile.write("---------------------------------------------------------\n")
                        done = True
                    count += 1
                    ofile.write(f"{sc:{l_max}} {tf_idf:>7.3f} {tf:>7.3f} {df:>7.3f}\n")
