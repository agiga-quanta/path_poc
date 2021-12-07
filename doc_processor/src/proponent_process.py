__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


import re
from regex_process import OP_MAP


class ProponentProcessor(object):

    def __init__(self, config):
        self.CORRECT = self.init_ops(config.get_eval_option('proponent', 'correct'))
        self.EXTRACT = self.init_ops(config.get_eval_option('proponent', 'extract'))
        self.CLEANUP = self.init_ops(config.get_eval_option('proponent', 'cleanup'))
    
    def init_ops(self, ops):
        for op in ops:
            op['func'] = OP_MAP[op['func']]
            op['ex'] = re.compile(op['ex']) if 'c' in op and op['c'] else re.compile(op['ex'], re.IGNORECASE)
        return ops

    def extract(self, text, nlp):
        section = dict()
        # print('GIVEN -----\n%s\n----- GIVEN\n' % text)

        for op in self.CORRECT:
            text = op['func'](op, text)
        # print('CORRECTED -----\n%s\n----- CORRECTED\n' % text)

        for op in self.EXTRACT:
            r = op['func'](op, text)
            if isinstance(r, dict) and r:
                for k, v in r.items():
                    if k not in section:
                        section[k] = [] 
                    if v not in section[k]:
                        section[k].append(v)
                    text = text.replace(v, ' ')
        # print('EXTRACTED -----\n%s\n----- EXTRACTED\n' % text)

        text = text.replace('\n', ', ')
        for op in self.CLEANUP:
            text = op['func'](op, text)
        # print('CLEANUP -----\n%s\n----- CLEANUP\n' % text)

        nlp_doc = nlp.process(text)
        entities = nlp_doc['sentences'][0]['entitymentions']
        used_entities = set()
        search_list = ['ORGANIZATION', 'PERSON', 'TITLE']
        i = 0
        f_end = 0
        while i < min(len(search_list), len(entities)):
            e_ner, e_txt, e_beg, e_end = entities[i]['ner'], entities[i]['text'], entities[i]['characterOffsetBegin'], entities[i]['characterOffsetEnd']
            if e_ner in search_list:
                if e_ner.lower() not in section:
                    section[e_ner.lower()] = []
                if e_txt not in section[e_ner.lower()]:
                    section[e_ner.lower()].append(e_txt)
                f_end = e_end + 1
                used_entities.add(e_beg)
            i += 1
        
        entities = nlp_doc['sentences'][0]['entitymentions'][::-1]
        search_list = ['PERSON','STATE_OR_PROVINCE', 'LOCATION', 'CITY']
        i = 0
        b_end = len(text)
        while i < min(len(search_list), len(entities)):
            e_ner, e_txt, e_beg = entities[i]['ner'], entities[i]['text'], entities[i]['characterOffsetBegin']
            if e_beg not in used_entities and e_ner in search_list:
                if e_ner.lower() not in section:
                    section[e_ner.lower()] = []
                if e_txt not in section[e_ner.lower()]:
                    section[e_ner.lower()].append(e_txt)
                b_end = e_beg - 1
            i += 1

        text = text[f_end:b_end]

        for op in self.CLEANUP:
            text = op['func'](op, text)
        if text and text.strip():
            if 'place' in section:
                if text.strip() not in section:
                    section['place'].append(text.strip())
            else:
                section['place'] = [text.strip()]

        print('\nPROPONENT -----')
        for k in section.keys():
            v = section[k]
            if k not in ['s', 'e', 'val']:
                print(f"{k:20} {v}")

        return section
