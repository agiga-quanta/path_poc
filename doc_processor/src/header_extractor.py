__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from collections import Counter
from regex_process import init_ops


class HeaderExtractor(object):

    def __init__(self, config):
        self.CLEANER = init_ops(config.get_eval_option('header_extractor', 'cleaner'))
        self.ID_LIST = init_ops(config.get_eval_option('header_extractor', 'id_list'))
        self.CROSS = init_ops(config.get_eval_option('header_extractor', 'cross_context'))
        self.FIXER = init_ops(config.get_eval_option('header_extractor', 'fixer'))
        self.VERIFY = init_ops(config.get_eval_option('header_extractor', 'verify'))
        self.DEBUG = int(config.get_config_option('header_extractor', 'debug'))
    
    def process(self, text):
        if self.DEBUG >= 1:
            print('\nFILE ID(s) -----')

        for op in self.CLEANER:
            text = op['func'](op, text)
        
        match_dict = dict()
        for op in self.ID_LIST:
            m_dict, text = op['func'](op, text)
            for k, v in m_dict.items():
                if k not in match_dict:
                    match_dict[k] = []
                cv = []
                for ev in v:
                    for fix in self.FIXER:
                        ev = fix['func'](fix, ev)
                    cv.append(ev)
                match_dict[k].extend(cv)

        for op in self.CROSS:
            m_dict, text = op['func'](op, text)
            for k, v in m_dict.items():
                if k not in match_dict:
                    match_dict[k] = []
                match_dict[k].extend(v)

        if self.DEBUG == 2:
            for k, v in match_dict.items():
                print(f"{k:20} {v}")

        for k in match_dict.keys():
            if k in ['URL', 'email']:
                continue
            match_dict[k] = Counter(match_dict[k]).most_common(1)[0]

        if self.DEBUG == 3:
            print('ID_LIST -----\n%s\n----- ID_LIST' % text)

        assert {'authorization_no', 'dfo_file_no', 'path_no'}.intersection(match_dict.keys()) is not None
        assert all([regex['func'](regex, text) is None for regex in self.VERIFY]), match_dict

        if self.DEBUG >= 1:
            for k in match_dict.keys():
                print(f"{k:20} {match_dict[k]}")

        return match_dict, text
