__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from copy import deepcopy

import geocoder
import requests

from regex_process import init_ops


class LocationExtractor(object):

    def __init__(self, config):
        self.MAX_TAG = int(config.get_eval_option('location_extractor', 'max_tag'))
        self.EXTRACT = init_ops(config.get_eval_option('location_extractor', 'extract'))
        self.CLEANUP = init_ops(config.get_eval_option('location_extractor', 'cleanup'))
        self.DOC_4_TAGS = init_ops(config.get_eval_option('location_extractor', 'doc_4_tags'))
        self.DEBUG = int(config.get_config_option('location_extractor', 'debug'))
        self.session = requests.Session()
    
    def extract(self, doc_text, doc_id):
        section = dict()
        text = deepcopy(doc_text)

        if self.DEBUG >= 1:
            print('\nLOCATION -----')

        for op in self.EXTRACT:
            text_copy = deepcopy(text)
            r = op['func'](op, text_copy)
            if isinstance(r, dict) and r:
                for k, v in r.items():
                    if k not in section:
                        section[k] = [] 
                    if v not in section[k]:
                        section[k].append(v)
                    text_copy = text_copy.replace(v, ' ')
            if len(section) >= self.MAX_TAG:
                break

        assert len(section) >= self.MAX_TAG or \
            (len(section) == self.MAX_TAG - 1 and any([op['func'](op, doc_id) is not None for regex in self.DOC_4_TAGS])), section

        for k in section.keys():
            e = section[k][0]
            for op in self.CLEANUP:
                e = op['func'](op, e)
            section[k] = e

        hdrs = [
            ['nearest_community', 'municipality', 'province'],
            ['municipality', 'nearest_community', 'province'],
            ['municipality', 'province'],
            ['nearest_community', 'province'],
        ]
        for hdr in hdrs:
            loc = ', '.join([
                section[name][section[name].find(' of ') + 4 if ' of ' in section[name] else 0:]
                for name in hdr if name in section
            ])
            g = geocoder.osm(loc, session=self.session)
            if g.latlng:
                print(loc, g.latlng)
                section['geocode'] = g.latlng
                break    
        if 'geocode' not in section:
            section['geocode'] = []
        
        for k in section.keys():
            if self.DEBUG == 1:
                print(f"{k:20} {section[k]}")

        for k in ['nearest_community', 'municipality', 'province', 'watercourse', 'geo_location']:
            if k not in section:
                section[k] = ''

        return section
