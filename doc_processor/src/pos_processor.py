__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


import re
from nltk.corpus import stopwords
from nltk.stem.snowball import EnglishStemmer
from nltk.tree import ParentedTree


class POSProcessor(object):

    def __init__(self, config):
        self.DEBUG = int(config.get_config_option('pos_processor', 'debug'))
        self.NE_TAGS = config.get_eval_option('pos_processor', 'ne_tags')
        self.stemmer = EnglishStemmer()
        self.stopwords = stopwords.words('english')

    def collect_phrases(self, sentence):
        if self.DEBUG > 1:
            print(sentence['c'])
        parented_tree = ParentedTree.fromstring(sentence['parse'])
        tokens = sentence['tokens']
        idx, id2 = -1, set()

        for subtree in parented_tree.subtrees(lambda t: t.height() == 2):
            idx += 1
            token = tokens[idx]
            if subtree[0] in ['-LRB-', '-RRB-'] or \
                not subtree[0].isalpha() or \
                    token['ner'] in self.NE_TAGS:
                continue
            assert subtree[0] == token['word'], f"{subtree} {token}\n {tokens}"
            token['stem'] = self.stemmer.stem(token['lemma'].lower())
            subtree[0] = token
            id2.add(idx)

        sentence['key_phrases'] = []
        for subtree in parented_tree.subtrees(lambda t: t.height() == 3):
            words = [l for l in subtree.leaves() if not isinstance(l, str)]
            word_lists = [[]]
            for w in words:
                if w['ner'] in self.NE_TAGS:
                    continue
                if not word_lists[-1] or word_lists[-1][-1]['ner'] == w['ner']:
                    word_lists[-1].append(w)
                else:
                    word_lists.append([w])
                id2.discard(w['index']-1)

            for word_list in word_lists:
                if not word_list:
                    continue
                sentence['key_phrases'].append({
                    'o': ' '.join(w['originalText'] for w in word_list),
                    'l': ' '.join(w['lemma'] for w in word_list),
                    'p': '-'.join(w['pos'] for w in word_list),
                    'w': [w for w in word_list if w['lemma'].lower() not in self.stopwords]
                })

        for i2 in id2:
            if tokens[i2]['lemma'].lower()  not in self.stopwords:
                sentence['key_phrases'].append({
                    'o': tokens[i2]['originalText'],
                    'l': tokens[i2]['lemma'],
                    'p': tokens[i2]['pos'],
                    'w': [tokens[i2]]
                })

        entity_lists = [[]]
        for entity in sentence['entitymentions']:
            if (not entity_lists[-1]) or \
                (('tokenBegin' in entity) and \
                    (entity_lists[-1][-1]['ner'] == entity['ner'] and \
                        entity_lists[-1][-1]['tokenEnd'] == entity['tokenBegin'])):
                entity_lists[-1].append(entity)
                continue
            
            entity_lists.append([entity])

        entities = []
        for entity_list in entity_lists:
            if not entity_list:
                continue
            if len(entity_list) == 1:
                entities.append(entity_list[0])
            else:
                entities.append({
                    'docTokenBegin': entity_list[0]['docTokenBegin'],
                    'docTokenEnd': entity_list[-1]['docTokenEnd'],
                    'tokenBegin': entity_list[0]['tokenBegin'],
                    'tokenEnd': entity_list[-1]['tokenEnd'],
                    'text': ' '.join([e['text'] for e in entity_list]),
                    'characterOffsetBegin': entity_list[0]['characterOffsetBegin'],
                    'characterOffsetEnd': entity_list[-1]['characterOffsetEnd'],
                    'ner': entity_list[0]['ner']
                })
        sentence['named_entities'] = entities

        for hdr in [ 'entitymentions', 'tokens', 'parse', 'basicDependencies', 'enhancedDependencies', 'enhancedPlusPlusDependencies' ]:
            sentence.pop(hdr)
