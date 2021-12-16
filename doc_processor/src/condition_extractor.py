__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from copy import deepcopy
from regex_process import init_ops


class ConditionExtractor(object):

    def __init__(self, config):
        self.CORRECT = init_ops(config.get_eval_option('condition_extractor', 'correct'))
        self.EXTRACT = init_ops(config.get_eval_option('condition_extractor', 'extract'))
        self.CLEANER = init_ops(config.get_eval_option('condition_extractor', 'cleaner'))
        self.DEBUG = config.get_eval_option('condition_extractor', 'debug')
    
    def extract(self, doc_text, nlp, spl, doc_id):
        section = []
        text = deepcopy(doc_text)

        for op in self.CORRECT:
            text = op['func'](op, text)

        if self.DEBUG >= 1:
            print('\nCONDITIONS -----')

        if self.DEBUG == 3:
            print('CONDITIONS -----\n%s\n----- CONDITIONS\n' % text)

        for op in self.EXTRACT:
            r_list = op['func'](op, text)
            if isinstance(r_list, list) and r_list:
                for r in r_list:
                    # print(r)
                    section.append(r)

        bullets = list([r[0] for r in section])
        for i in range(0, len(bullets)):
            if i == 0:
                next_b = [e for e in bullets[i].split('.') if e]
                assert len(next_b) == 1 and int(next_b[0]) == 1, f"FIRST {next_b}"
            else:
                prev_b, next_b = [e for e in bullets[i-1].split('.') if e], [e for e in bullets[i].split('.') if e]
                if len(prev_b) == len(next_b):
                    assert int(prev_b[-1]) + 1 == int(next_b[-1]), f"LAST {bullets[i-1]} {bullets[i]}"
                    if len(prev_b) > 1:
                        assert all([prev_b[i] == next_b[i] for i in range(0, len(prev_b)-1)]), f"BETWEEN {bullets[i-1]} {bullets[i]}"
                elif len(prev_b) > len(next_b):
                    assert int(prev_b[len(next_b)-1]) + 1 == int(next_b[-1]), f"SIBLING {bullets[i-1]} {bullets[i]}"
                    if len(next_b) > 1:
                        assert all([prev_b[i] == next_b[i] for i in range(0, len(next_b)-1)]), f"PREVIOUS {bullets[i-1]} {bullets[i]}"
                else:   # len(prev_b) < len(next_b):
                    assert len(prev_b) + 1 == len(next_b), f"CHILD {bullets[i-1]} {bullets[i]}"
                    if len(prev_b) > 1:
                        assert all([prev_b[i] == next_b[i] for i in range(0, len(prev_b)-1)]), f"EARLIER {bullets[i-1]} {bullets[i]}"

        for i in range(0, len(section)):
            bullet, content = section[i]
            for op in self.CLEANER:
                content  = op['func'](op, content)
            content = content.replace('\n', ' ')
            assert len(content) > 0
            section[i][1] = content

        for i in range(0, len(section)):
            content = section[i][1]
            nlp_doc = nlp.process(content)
            spl.process(nlp_doc, doc_id)
            section[i][1] = { 't': content, 'nlp': nlp_doc}

        if self.DEBUG >= 1:
            if self.DEBUG == 1:
                print(' '.join(['(%s %s)' % (bullet, len(content['t'])) for bullet, content in section]))
            elif self.DEBUG == 2:
                for bullet, content in section:
                    print(f"{bullet:20} {len(content)}\n[{content['t']}]")
            else:
                for bullet, content in section:
                    print(f"{bullet:20} {len(content)}\n\t[{content['t']}]\n\t[{content['nlp']}]")
           
        return section
