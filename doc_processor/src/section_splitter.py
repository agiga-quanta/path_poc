__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from regex_process import init_ops


class SectionSplitter(object):

    def __init__(self, config):
        self.WORDS = init_ops(config.get_eval_option('section_splitter', 'st_word'))
        self.NAMES = config.get_eval_option('section_splitter', 'st_name')
        self.POSTS = config.get_eval_option('section_splitter', 'st_post')
        self.SUBS = init_ops(config.get_eval_option('section_splitter', 'st_subs'))
        self.DEBUG = int(config.get_config_option('section_splitter', 'debug'))

    def get_text(self, text, anchors, section_info):
        prev_section, prev_t, curr_section, curr_t = section_info
        if curr_section:
            return text[anchors[prev_section][prev_t]:anchors[curr_section][curr_t]]
        return text[anchors[prev_section][prev_t]:]

    def split(self, text):
        sections = dict()

        if self.DEBUG >= 1:
            print('\nSECTIONS -----')

        from_pos = 0
        for op in self.WORDS:
            r = op['func'](op, text, from_pos)
            try:
                if self.DEBUG >= 2:
                    print("[%s]\t[%d:%d]" % (r['k'], r['s'], r['e']))
                sections[r['k']] = {'s': r['s'], 'e': r['e']}
            except TypeError as te:
                print(op['ex'])
                print(text[from_pos:])
                exit(1)
            from_pos = r['e']
    
        for name in self.NAMES:
            val = self.get_text(text, sections, self.POSTS[name])
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

        if self.DEBUG >= 1:
            for name, section in sections.items():
                section = sections[name]
                s, e, l, t = section['s'], section['e'], len(section['t']), section['t']
                if self.DEBUG == 1:
                    print(f"{name:20} {s:10} {e:10} {l:10}")
                elif self.DEBUG == 2:
                    print(f"\n{name:20} {s:10} {e:10} {l:10}\n>>>>>\n{t}\n<<<<<")

        return sections

