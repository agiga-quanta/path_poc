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


class DescriptionProcessor(object):

    def __init__(self, config):
        self.CORRECT = self.init_ops(config.get_eval_option('description', 'correct'))
        self.COMMONS = {
            elem_name: self.init_ops([op]).pop()
            for elem_name, op in config.get_eval_option('description', 'commons').items()
        }
        self.PROCESS = config.get_eval_option('description', 'process')
        for process in self.PROCESS:
            process['extract'] = [self.COMMONS[elem_name] for elem_name in process['extract']]
        self.ELEMENT = config.get_eval_option('description', 'element')

    def init_ops(self, ops):
        for op in ops:
            op['func'] = OP_MAP[op['func']]
            op['ex'] = re.compile(op['ex']) if 'c' in op and op['c'] else re.compile(op['ex'], re.IGNORECASE)
        return ops

    def get_text(self, text, element_list, element_info):
        prev_section, prev_t, curr_section, curr_t = element_info
        if prev_section:
            if curr_section:
                return text[element_list[prev_section][prev_t]:element_list[curr_section][curr_t]]
            else:
                return text[element_list[prev_section][prev_t]:]
        else:
            if curr_section:
                return text[:element_list[curr_section][curr_t]]

    def extract(self, text, nlp):
        elements = dict()
        # given_text = deepcopy(text)
        # print('GIVEN -----\n%s\n----- GIVEN\n' % given_text)

        for op in self.CORRECT:
            text = op['func'](op, text)
        correct_text = deepcopy(text)

        for process in self.PROCESS:
            attempt = dict()
            from_pos = 0
            for op in process['extract']:
                r = op['func'](op, text, from_pos)
                if isinstance(r, dict):
                    # print("[%s]\t[%d:%d]" % (r['k'], r['s'], r['e']))
                    attempt[r['k']] = {'s': r['s'], 'e': r['e']}
                    from_pos = r['e']

            if len(process['position']) - len(attempt) == 1 and 'padding' in process:
                attempt[process['padding']] = {'s': 0, 'e': 0}
            if len(attempt) == len(process['position']):
                for name, length in self.ELEMENT.items():
                    if name in process['position']:
                        val = self.get_text(text, attempt, process['position'][name])
                        assert len(val) > length, '[%s] %s %s  [%s]' % (name, len(val), length, val)
                        attempt[name]['t'] = val
                    elements = attempt
                break
        
        assert elements, 'CORRECT -----\n%s\n----- CORRECT\n' % correct_text
        
        print('\nDESCRIPTION -----')
        for name, element in elements.items():
            s, e, l = element['s'], element['e'], len(element['t'])
            print(f"{name:20} {s:10} {e:10} {l:10}")
            element['t'] = element['t'].replace('\n', ' ')
            nlp_doc = nlp.process(element['t'])
            element['nlp'] = nlp_doc

        return elements

