__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from collections import Counter
from regex_process import init_ops

MONTH_MAP = {
    "JAN": "1", "FEB": "2", "MAR": "3", "APR": "4", "MAY": "5", "JUN": "6",
    "JUL": "7", "AUG": "8", "SEP": "9", "OCT": "10", "NOV": "11", "DEC": "12",
}

class HeaderExtractor(object):

    def __init__(self, config):
        self.CLEANER = init_ops(config.get_eval_option('header_extractor', 'cleaner'))
        self.ID_LIST = init_ops(config.get_eval_option('header_extractor', 'id_list'))
        self.ETX_LIST = init_ops(config.get_eval_option('header_extractor', 'etx_list'))
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

        for op in self.ETX_LIST:
            r = op['func'](op, text)
            if isinstance(r, dict) and r:
                for k, v in r.items():
                    if k not in match_dict:
                        match_dict[k] = [] 
                    if v not in match_dict[k]:
                        match_dict[k].append(v)

        for op in self.CROSS:
            m_dict, text = op['func'](op, text)
            for k, v in m_dict.items():
                if k not in match_dict:
                    match_dict[k] = []
                match_dict[k].extend(v)

        for k in match_dict.keys():
            if self.DEBUG == 2:
                print(f"{k:20} {v}")
            if k in ['URL', 'email']:
                continue
            match_dict[k] = Counter(match_dict[k]).most_common(1)[0][0]

        if self.DEBUG == 3:
            print('ID_LIST -----\n%s\n----- ID_LIST' % text)

        assert {'authorization_no', 'dfo_file_no', 'path_no'}.intersection(match_dict.keys()) is not None
        assert all([regex['func'](regex, text) is None for regex in self.VERIFY]), match_dict

        for k in ['authorization_no', 'dfo_file_no', 'path_no', 'date_of_issuance']:
            if k not in match_dict:
                match_dict[k] = ''
            else:
                if k == 'date_of_issuance':
                    splits = match_dict[k].split()
                    match_dict[k] = '%s-%s-%s' % (splits[2], MONTH_MAP[splits[0]], splits[1])
                else:
                    match_dict[k] = match_dict[k][match_dict[k].find(':')+1:].strip()

        if self.DEBUG >= 1:
            for k in match_dict.keys():
                print(f"{k:20} {match_dict[k]}")

        return match_dict, text
