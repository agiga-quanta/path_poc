__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"

from collections import Counter, defaultdict
import re
from regex_process import OP_MAP


class HeaderCleaner(object):

    def __init__(self, config):
        self.SPLIT = config.get_eval_option('page', 'split')
        self.FOOTERS = self.init_ops(config.get_eval_option('page', 'footers'))
        self.HEADERS = self.init_ops(config.get_eval_option('page', 'headers'))
        self.POST_PR = self.init_ops(config.get_eval_option('page', 'post_pr'))
        self.reset()
    
    def init_ops(self, ops):
        for op in ops:
            op['func'] = OP_MAP[op['func']]
            op['ex'] = re.compile(op['ex']) if 'c' in op and op['c'] else re.compile(op['ex'], re.IGNORECASE)
            if 'i' in op:
                op['i'] = re.compile(op['i'])
        return ops

    def reset(self):
        self.info = defaultdict(list)

    def process(self, p_list):
        sp_list = []
        for p in p_list:
            found = False
            for pref, post in self.SPLIT:
                idx = p.find(post)
                if p.startswith(pref) and idx > 0:
                    sp_list.extend([p[:idx+1], p[idx+1:]])
                    break
            if not found:
                sp_list.append(p)

        p_list = sp_list
        start, found = 0, False
        while not found and start < len(p_list):
            t = p_list[start]
            for op in self.HEADERS:
                r = op['func'](op, t)
                if r is None:
                    start += 1
                    break
                if isinstance(r, dict):
                    for k, v in r.items():
                        self.info[k].append(v)
                    # t_n = t[t.find('\n'):]
                    # if len(t_n) >  10:
                    #     p_list[start] = t_n
                    #     found = True
                    # else:
                    #     start += 1
                    start += 1
                    break
            if r == t:
                found = True
        
        r_list, end, found = p_list[start:][::-1], 0, False
        while not found and end < len(r_list):
            t = r_list[end]
            for op in self.FOOTERS:
                r = op['func'](op, t)
                if r is None:
                    end += 1
                    break
            if r == t:
                found = True

        return r_list[end:][::-1]

    def get_info(self):
        r = dict()

        for k, v in self.info.items():
            t = Counter(v).most_common(1).pop()[0]
            for op in self.POST_PR:
                t = op['func'](op, t)
                r[k] = t

        assert {'authorization_no', 'dfo_file_no', 'path_no'}.intersection(r.keys()) is not None
        print('\nFILE ID(s) -----')
        for k, v in r.items():
            print(f"{k:20} {v}")

        return r
