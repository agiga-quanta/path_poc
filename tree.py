from json import load
from itertools import groupby
import sys

from nltk.tree import ParentedTree
from nltk.stem.snowball import EnglishStemmer
from nltk.corpus import stopwords


stemmer = EnglishStemmer()
stopwords = [] # stopwords.words('english')

with open(sys.argv[1], 'rt') as json_file:
    nlp_json = load(json_file)
    
    for sentence in nlp_json['sentences']:
        parented_tree = ParentedTree.fromstring(sentence['parse'])
        tokens = sentence['tokens']
        idx, id2, id3 = -1, set(), []
        for subtree in parented_tree.subtrees(lambda t: t.height() == 2):
            idx += 1
            if subtree[0] in ['-LRB-', '-RRB-'] or \
                not subtree[0].isalpha() or \
                    tokens[idx]['ner'] in ['BUILDING', 'FOOTPRINT']:
                continue
            assert subtree[0] == tokens[idx]['originalText']
            if tokens[idx]['lemma'].lower() not in stopwords:
                tokens[idx]['stem'] = stemmer.stem(tokens[idx]['lemma'])
                subtree[0] = tokens[idx]
                id2.add(idx)

        sentence['key_phrases'] = []
        for subtree in parented_tree.subtrees(lambda t: t.height() == 3):
            words = [l for l in subtree.leaves() if not isinstance(l, str)]
            word_lists = [[]]
            for w in words:
                if w['ner'] in ['BUILDING', 'FOOTPRINT']:
                    continue
                if not word_lists[-1] or word_lists[-1][-1]['ner'] == w['ner']:
                    word_lists[-1].append(w)
                else:
                    word_lists.append([w])
                id2.discard(w['index']-1)

            for word_list in word_lists:
                sentence['key_phrases'].append({
                    'o': ' '.join(w['originalText'] for w in word_list),
                    'l': ' '.join(w['lemma'] for w in word_list),
                    'p': '-'.join(w['pos'] for w in word_list),
                    'w': word_list
                })

        for i2 in id2:
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

        print('named_entities\n', sentence['named_entities'])
        print('key_phrases\n', sentence['key_phrases'])
