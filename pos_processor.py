__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


import re


class POSProcessor(object):

    def __init__(self, config):
        self.DEBUG = int(config.get_config_option('pos_processor', 'debug'))

    def collect_phrases(self, tok_list, grammar, collect, min_len_word=3):
        tok_dict = { t['index']: t for t in tok_list }
        pos_dict = dict()
        id_xpos_list = ' '.join('%s_%s' % (t['index'], t['pos']) for t in tok_list)

        if self.DEBUG >= 2:
            print(id_xpos_list)
            print(' '.join('%s_%s_%s' % (t['index'], t['pos'], t['word']) for t in tok_list))
            
        for match in grammar.finditer(id_xpos_list):  # Lookup based on `grammar`
            s, e = match.start(), match.end()

            # Collect matched pair (word index, xpos_tag) based on `collect`
            words = [ { 
                'l': tok_dict[int(idx)]['lemma'],
                't': tok_dict[int(idx)]['word'],
                'o': tok_dict[int(idx)]['originalText'],
                'p': pos_tag,
            } for idx, pos_tag in collect.findall(id_xpos_list[s:e]) ]

            # Create new phrase
            phrase = ' '.join([w['l'] for w in words])
            if phrase and len(phrase) >= min_len_word:
                if phrase not in pos_dict:
                    pos_dict[phrase] = {
                        'c': ' '.join([w['l'] for w in words]),
                        't': ' '.join([w['o'] for w in words]),
                        'w': words,
                        'tf': 0.0
                    }
                pos_dict[phrase]['tf'] += 1.0
            
        return pos_dict
