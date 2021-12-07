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


class ConditionProcessor(object):

    def __init__(self, config):
        self.CORRECT = self.init_ops(config.get_eval_option('condition', 'correct'))
        self.EXTRACT = self.init_ops(config.get_eval_option('condition', 'extract'))
    
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
        correct_text = deepcopy(text)
        # print('nCORRECTED -----\n%s\n----- CORRECTED\n' % correct_text)

        for op in self.EXTRACT:
            r_list = op['func'](op, text)
            if isinstance(r_list, list) and r_list:
                for r in r_list:
                    section.update({ r[0]: r[1] })

        print('\nCONDITIONS -----')
        for k in sorted(section.keys()):
            v = section[k]
            assert len(v) > 0
            print(f"{k:20} {len(v)}")

            v = v.replace('\n', ' ')
            nlp_doc = nlp.process(v)
            section[k] = {'t': v, 'nlp': nlp_doc}
        
        return section
