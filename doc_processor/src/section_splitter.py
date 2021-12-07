__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


import re
from regex_process import OP_MAP


class SectionSplitter(object):

    def __init__(self, config):
        self.CLEAN = self.init_ops(config.get_eval_option('section', 'cleaner'))
        self.WORDS = self.init_ops(config.get_eval_option('section', 'st_word'))
        self.NAMES = config.get_eval_option('section', 'st_name')
        self.POSTS = config.get_eval_option('section', 'st_post')
        self.SUBS = self.init_ops(config.get_eval_option('section', 'st_subs'))

    def init_ops(self, ops):
        for op in ops:
            op['func'] = OP_MAP[op['func']]
            op['ex'] = re.compile(op['ex']) if 'c' in op and op['c'] else re.compile(op['ex'], re.IGNORECASE)
        return ops

    def get_text(self, text, anchors, section_info):
        prev_section, prev_t, curr_section, curr_t = section_info
        if curr_section:
            return text[anchors[prev_section][prev_t]:anchors[curr_section][curr_t]]
        return text[anchors[prev_section][prev_t]:]

    def split(self, t_list):
        pt_list = []
        for t in t_list:
            for op in self.CLEAN:
                t = op['func'](op, t)
            pt_list.append(t if t.endswith('\n') else t + '\n')

        doc = ''.join(pt_list)
        sections = dict()
        from_pos = 0
        for op in self.WORDS:
            r = op['func'](op, doc, from_pos)
            sections[r['k']] = {'s': r['s'], 'e': r['e']}
            # print("[%s]\t[%d:%d]" % (r['k'], r['s'], r['e']))
            from_pos = r['e']
    
        for name in self.NAMES:
            val = self.get_text(doc, sections, self.POSTS[name])
            sections[name]['t'] = val
            assert len(val) > self.NAMES[name], '[%s] [%s]' % (name, val)
    
        for op in self.SUBS:
            from_section = sections[op['from']]
            r = op['func'](op, from_section['t'])
            if isinstance(r, dict):
                for name, pos in r.items():
                    sections[name] = {'s': from_section['s'] + pos, 'e': from_section['s'] + len(from_section['t']), 't': from_section['t'][pos:]}
                    from_section['e'] = from_section['s'] + pos
                    from_section['t'] = from_section['t'][:pos]

        print('\nSECTIONS -----')
        for name, section in sections.items():
            section = sections[name]
            s, e, l = section['s'], section['e'], len(section['t'])
            print(f"{name:20} {s:10} {e:10} {l:10}")

        return sections

