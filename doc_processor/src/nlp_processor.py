__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from json import decoder
import requests


class NLPProcessor(object):

    def __init__(self, config):
        self.STANFORD_URL = config.get_config_option('nlp_processor', 'url')

    def process(self, text):
        res = requests.post(self.STANFORD_URL, headers={"Content-Type": "plain/text"}, data=bytes(text, 'utf-8'))
        try:
            r = res.json()
            if r and 'sentences' in r:
                for s in r['sentences']:
                    if not s:
                        continue
                    s_tok, e_tok = s['tokens'][0], s['tokens'][-1]
                    s['c'] = text[s_tok['characterOffsetBegin']:e_tok['characterOffsetEnd']]
            return r
        except decoder.JSONDecodeError as de:
            print(de, res)
            return []
