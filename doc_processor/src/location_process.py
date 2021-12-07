__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from copy import deepcopy
import re
from regex_process import OP_MAP


class LocationProcessor(object):

    def __init__(self, config):
        self.MAX_TAG = int(config.get_eval_option('location', 'max_tag'))
        self.CORRECT = self.init_ops(config.get_eval_option('location', 'correct'))
        self.EXTRACT = self.init_ops(config.get_eval_option('location', 'extract'))
        self.CLEANUP = self.init_ops(config.get_eval_option('location', 'cleanup'))
    
    def init_ops(self, ops):
        for op in ops:
            op['func'] = OP_MAP[op['func']]
            op['ex'] = re.compile(op['ex']) if 'c' in op and op['c'] else re.compile(op['ex'], re.IGNORECASE)
        return ops

    def extract(self, text, nlp):
        section = dict()
        # given_text = deepcopy(text)
        # print('GIVEN -----\n%s\n----- GIVEN\n' % given_text)

        for op in self.CORRECT:
            text = op['func'](op, text)
        # print('CORRECTED -----\n%s\n----- CORRECTED\n' % text)

        for op in self.EXTRACT:
            text_copy = deepcopy(text)
            r = op['func'](op, text_copy)
            if isinstance(r, dict) and r:
                for k, v in r.items():
                    if k not in section:
                        section[k] = [] 
                    if v not in section[k]:
                        section[k].append(v)
                    text_copy = text_copy.replace(v, ' ')
            if len(section) >= self.MAX_TAG:
                break

        print('\nLOCATION -----')
        for k in section.keys():
            v = section[k]
            if k not in ['s', 'e', 'val']:
                for op in self.CLEANUP:
                    v = [op['func'](op, e) for e in v]
                section[k] = v
                print(f"{k:20} {v}")

        return section
