__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


import re


class NLPProcessor(object):

    def __init__(self, config):
        self.GRAMMAR = re.compile(config.get_config_option('pos', 'grammar'))
        self.COLLECT = re.compile(config.get_config_option('pos', 'collect'))
        self.MIN_WORD = int(config.get_config_option('pos', 'min_word'))
        self.LABEL_MAP = config.get_eval_option('gather', 'label_map')
        self.ASIS = config.get_eval_option('gather', 'as_is')
        self.PRFX = config.get_eval_option('gather', 'prefix')

    def collect_entities(self, sent_ent_list, sent_token_dict, doc_ent_dict):
        sent_ent_set = set()

        for e in sent_ent_list:
            sent_ent_set.add(e['text'])
            if e['text'] not in doc_ent_dict:
                doc_ent_dict[e['text']] = {
                    't': e['ner'],
                    'c': e['text'],
                    'w': [ sent_token_dict[i+1]['lemma'] for i in range(e['tokenBegin'], e['tokenEnd']) ],
                    'n': e['normalizedNER'] if 'normalizedNER' in e else '',
                    'tf': 0.0
                }
            doc_ent_dict[e['text']]['tf'] += 1.0

        return sent_ent_set

    def add_entities(self, element_name, element, doc_ent_dict):
        e_ner = self.LABEL_MAP[element_name] if element_name in self.LABEL_MAP else element_name.upper()
        if not e_ner:
            return

        e_list = element
        if not isinstance(element, list):
            e_list = [element]
        
        for e in e_list:
            if e not in doc_ent_dict:
                doc_ent_dict[e] = {
                    't': e_ner,
                    'c': e,
                    'w': e.split(),
                    'tf': 0.0
                }
            doc_ent_dict[e]['tf'] += 1.0

    def collect_phrases(self, sent_tok_list, sent_token_dict, doc_pos_dict):
        sent_pos_set = set()
        id_xpos_list = ' '.join('%s_%s' % (t['index'], t['pos']) for t in sent_tok_list)

        match = self.GRAMMAR.search(id_xpos_list)  # Lookup based on `grammar`
        while match:
            s, e = match.start(), match.end()

            # Collect matched pair (word index, xpos_tag) based on `collect`
            tag_ids = [i for i, _ in self.COLLECT.findall(id_xpos_list[s:e])]

            words = [ 
                { 'l': sent_token_dict[int(i)]['lemma'] } 
                for i in tag_ids
                # if len(sent_token_dict[int(i)]['lemma']) >= self.MIN_WORD 
            ]

            # Create new key phrase
            content = ' '.join([w['l'] for w in words])
            if content and len(content) >= self.MIN_WORD:
                sent_pos_set.add(content)
                if content not in doc_pos_dict:
                    doc_pos_dict[content] = {
                        'c': content,
                        'w': words,
                        'tf': 0.0
                    }
                doc_pos_dict[content]['tf'] += 1.0

            match = self.GRAMMAR.search(id_xpos_list, e+1)

        return sent_pos_set

    def process(self, doc):
        sent_list = []
        ent_dict = dict()
        pos_dict = dict()
        info_dict = dict()

        for sect_id, doc_sect in doc.items():
            if sect_id in self.ASIS:
                info_dict[sect_id] =  doc_sect
                for elem_name, elem in doc_sect.items():
                    self.add_entities(elem_name, elem, ent_dict)
                continue

            for elem_name, elem in doc_sect.items():
                if elem_name.startswith(self.PRFX):
                    continue

                nlp = elem['nlp']
                for sentence in nlp['sentences']:
                    token_dict = {
                        token['index']: token for token in sentence['tokens']
                    }
                
                    ent_set = self.collect_entities(sentence['entitymentions'], token_dict, ent_dict)
                    pos_set = self.collect_phrases(sentence['tokens'], token_dict, pos_dict)
                    characterOffsetBegin = sentence['tokens'][0]['characterOffsetBegin']
                    characterOffsetEnd = sentence['tokens'][-1]['characterOffsetEnd']
                    sent_list.append({
                        'e': list(ent_set),
                        'p': list(pos_set),
                        't': elem['t'][characterOffsetBegin:characterOffsetEnd]
                    })
                        
        return sent_list, ent_dict, pos_dict, info_dict