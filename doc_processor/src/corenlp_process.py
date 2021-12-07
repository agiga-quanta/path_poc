import requests

from json import decoder

class CoreNLPProcessor(object):

    def __init__(self, config):
        # self.url = 'http://localhost:9000/?properties={"outputFormat":"json"}'
        self.url = config.get_config_option('corenlp', 'url')

    def process(self, text):
        res = requests.post(self.url, headers={"Content-Type": "plain/text"}, data=bytes(text, 'utf-8'))
        try:
            r = res.json()
            return r
        except decoder.JSONDecodeError as de:
            print(de, res)
            return []
        
        

