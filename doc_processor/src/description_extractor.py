__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from copy import deepcopy
from regex_process import init_ops


class DescriptionExtractor(object):

    def __init__(self, config):
        self.COMMONS = {
            elem_name: init_ops([op]).pop()
            for elem_name, op in config.get_eval_option('description_extractor', 'commons').items()
        }
        self.PROCESS = config.get_eval_option('description_extractor', 'process')
        for process in self.PROCESS:
            process['func'] = [self.COMMONS[elem_name] for elem_name in process['extract']]
        self.ELEMENT = config.get_eval_option('description_extractor', 'element')
        self.CLEANER = init_ops(config.get_eval_option('description_extractor', 'cleaner'))
        self.DEBUG = int(config.get_config_option('description_extractor', 'debug'))

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

    def extract(self, doc_text, nlp, spl, pos, doc_id):
        elements = dict()
        text = deepcopy(doc_text)

        if self.DEBUG >= 1:
            print('\nDESCRIPTIONS -----')

        found = False
        for process in self.PROCESS:
            attempt = dict()
            from_pos, items = 0, []
            for op in process['func']:
                r = op['func'](op, text, from_pos)
                if isinstance(r, dict):
                    # if self.DEBUG == 3:
                    # print("[%s]\t[%d:%d] [%s]" % (r['k'], r['s'], r['e'], text[r['s']: r['e']]))
                    attempt[r['k']] = {'s': r['s'], 'e': r['e'], 'k': text[r['s']: r['e']]}
                    items.append(r['k'])
                    from_pos = r['e']

            if len(process['position']) - len(attempt) == 1 and 'padding' in process:
                attempt[process['padding']] = {'s': 0, 'e': 0}
            
            found = len(attempt) == len(process['position']) and all([e1 == e2[:e2.rfind('_')] for e1, e2 in zip(items, process['extract'])])
            if found:
                for name, length in self.ELEMENT.items():
                    if name in process['position']:
                        val = self.get_text(text, attempt, process['position'][name])
                        assert len(val) > length, '[%s] %s %s  [%s]' % (name, len(val), length, val)
                        attempt[name]['t'] = val
                elements = attempt
                break

        assert found, 'GIVEN -----\n%s\n----- GIVEN\n%s\n' % (text, elements)

        for name, element in elements.items():
            for op in self.CLEANER:
                element['t']  = op['func'](op, element['t'] )
            element['t'] = element['t'].replace('\n', ' ')
            assert 'PARAGRAPH 35(2)(b) FISHERIES ACT AUTHORIZATION' not in element['t'], text

        if self.DEBUG == 1:
            print(' '.join(['(%s %s %s %s)' % (name, element['s'], element['e'], len(element['t'])) for name, element in elements.items()]))
        elif self.DEBUG > 1:
            for name, element in elements.items():
                s, e, l = element['s'], element['e'], len(element['t'])
                print(f"{name:20} {s:10} {e:10} {l:10}\n[{element['t']}]")

        section = list()
        for name, element in elements.items():
            if name.startswith('auth_'):
                continue
            nlp_doc = nlp.process(element['t'])
            if 'sentences' not in nlp_doc or not nlp_doc['sentences']:
                continue
            spl.process(nlp_doc, doc_id)
            for nlp_sent in nlp_doc['sentences']:
                pos.collect_phrases(nlp_sent)

            assert 'k' in element, '%s %s' % (name, element['t'])
            section.append({
                'name': name, 'k': element['k'], 't': element['t'], 's': nlp_doc['sentences']
            })
        
        return section
