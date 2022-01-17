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
    
    def extract(self, doc_text, nlp, spl, doc_id):
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
            cv = []
            for e in section[k]:
                for op in self.CLEANUP:
                    e = op['func'](op, e)
                nlp_doc = nlp.process(e)
                spl.process(nlp_doc, doc_id)
                cv.append({'t': e, 'nlp': nlp_doc})
            section[k] = cv

        loc = ', '.join([section[name][0]['t'] for name in ['nearest_community', 'municipality', 'province'] if name in section])
        g = geocoder.osm(loc, session=self.session)
        if g.latlng:
            section['geocode'] = [{'t': g.latlng}]
        else:
            loc = ', '.join([section[name][0]['t'] for name in ['nearest_community', 'province'] if name in section])
            g = geocoder.osm(loc, session=self.session)
            section['geocode'] = [{'t': g.latlng}]
        
        if self.DEBUG >= 1:
            for k in section.keys():
                if self.DEBUG == 1:
                    print(f"{k:20} {[v['t'] for v in section[k]]}")
                else:
                    print(f"{k:20} {section[k]}")

        return section
