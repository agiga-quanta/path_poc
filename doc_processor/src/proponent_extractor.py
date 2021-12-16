__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from copy import deepcopy
from regex_process import init_ops


class ProponentExtractor(object):

    def __init__(self, config):
        self.CORRECT = init_ops(config.get_eval_option('proponent_extractor', 'correct'))
        self.EXTRACT = init_ops(config.get_eval_option('proponent_extractor', 'extract'))
        self.CLEANUP = init_ops(config.get_eval_option('proponent_extractor', 'cleanup'))
        self.DEBUG = int(config.get_config_option('proponent_extractor', 'debug'))
    
    def extract(self, doc_text, nlp, spl, doc_id):
        section = dict()
        text = deepcopy(doc_text)

        if self.DEBUG >= 1:
            print('\nPROPONENT -----')

        for op in self.CORRECT:
            text = op['func'](op, text)

        for op in self.EXTRACT:
            r = op['func'](op, text)
            if isinstance(r, dict) and r:
                for k, v in r.items():
                    if k not in section:
                        section[k] = [] 
                    if v not in section[k]:
                        section[k].append(v)
                    text = text.replace(v, ' ')

        text = text.replace('\n', ', ')

        nlp_doc = nlp.process(text)
        spl.process(nlp_doc, doc_id)

        entities = sum([sent['entitymentions'] for sent in nlp_doc['sentences']], [])
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
                used_entities.add(e_beg)
                f_end = e_end + 1
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

        assert len(section) >= 4, section
        section['nlp'] = nlp_doc

        if self.DEBUG >= 1:
            for k in section.keys():
                if self.DEBUG == 1 and k == 'nlp':
                    continue
                print(f"{k:20} {section[k]}")

        return section
