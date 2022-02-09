__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


import re
from nltk.stem.snowball import EnglishStemmer


class POSProcessor(object):

    def __init__(self, config):
        self.DEBUG = int(config.get_config_option('pos_processor', 'debug'))
        self.EXTRACTORS = config.get_eval_option('pos_processor', 'extractors')
        for extractor in self.EXTRACTORS:
            extractor['grammar'] = re.compile(extractor['grammar'])
            extractor['collect'] = re.compile(extractor['collect'])
        self.stemmer = EnglishStemmer()

    def collect_phrases(self, tok_list, min_len_word=3):
        tok_dict = { t['index']: t for t in tok_list }
        pos_dict = dict()
        id_xpos_list = ' '.join('%s_%s' % (t['index'], t['pos']) for t in tok_list)

        if self.DEBUG >= 2:
            print(id_xpos_list)
            print(' '.join('%s_%s_%s' % (t['index'], t['pos'], t['word']) for t in tok_list))

        for extractor in self.EXTRACTORS:
            grammar, collect, entity = extractor['grammar'], extractor['collect'], extractor['entity']
            pos_dict[entity] = []
            pos_set = set()
            for match in grammar.finditer(id_xpos_list):  # Lookup based on `grammar`
                s, e = match.start(), match.end()

                # Collect matched pair (word index, xpos_tag) based on `collect`
                words = [ { 
                    'l': tok_dict[int(idx)]['lemma'],
                    's': self.stemmer.stem(tok_dict[int(idx)]['lemma']),
                    'o': tok_dict[int(idx)]['originalText'],
                    'p': pos_tag
                } for idx, pos_tag in collect.findall(id_xpos_list[s:e]) ]

                # Create new phrase
                phrase = ' '.join([w['l'] for w in words])
                if phrase and len(phrase) >= min_len_word and phrase not in pos_set:
                    pos_dict[entity].append({
                        't': ' '.join([w['l'] for w in words]),
                        'o': ' '.join([w['o'] for w in words]),
                        'w': words,
                    })
            
        return pos_dict
