__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from nltk.corpus import stopwords, wordnet
from regex_process import init_ops


class SpellChecker(object):

    def __init__(self, config):
        self.LEMMA_TO_IGNORE = config.get_eval_option('spell_checker', 'lemma_to_ignore')
        self.REGEX_TO_IGNORE = init_ops(config.get_eval_option('spell_checker', 'regex_to_ignore'))
        self.IGNORE_POS_TAGS = config.get_eval_option('spell_checker', 'ignore_pos_tags')
        self.DEBUG = int(config.get_config_option('spell_checker', 'debug'))
        self.stopwords = stopwords.words('english')
        self.unknown_dict = dict()
        self.known_dict = dict()
        self.detected_phrase_dict = dict()

    def process(self, nlp_doc, doc_id):        
        collector, prev_tok, next_tok = [], None, None
        for sentence in nlp_doc['sentences']:

            tokens = sentence['tokens']
            for idx in range(0, len(tokens)):

                lemma, pos, text = tokens[idx]['lemma'], tokens[idx]['pos'], tokens[idx]['originalText']
                if lemma in self.known_dict:
                    if pos not in self.known_dict[lemma]:
                        self.known_dict[lemma].add(pos)
                    continue

                old_unknown = lemma in self.unknown_dict
                if old_unknown and pos not in self.unknown_dict[lemma]:
                    self.unknown_dict[lemma].add(pos)
                
                if not old_unknown: 
                    new_unknown = not any([
                        lemma in self.stopwords, 
                        lemma.lower() in self.stopwords,
                        wordnet.synsets(lemma),
                        wordnet.synsets(lemma.lower()), 
                        wordnet.synsets(lemma.lower().capitalize()),
                        pos in self.IGNORE_POS_TAGS,
                        lemma in self.LEMMA_TO_IGNORE,
                        any([regex['func'](regex, text) is not None for regex in self.REGEX_TO_IGNORE])
                    ])

                unknown = old_unknown or new_unknown
                if unknown:
                    if not collector and idx > 0:
                        prev_tok = '%s_%s' % (tokens[idx-1]['originalText'], tokens[idx-1]['pos'])
                    collector.append([lemma, pos, text])
                
                if not unknown and collector:
                    if idx < len(tokens) - 1:
                        next_tok = '%s_%s' % (tokens[idx+1]['originalText'], tokens[idx+1]['pos'])
                    phrase = ' '.join([t for _, _, t in collector])
                    if phrase not in self.detected_phrase_dict:
                        self.detected_phrase_dict[phrase] = [0, prev_tok, collector, next_tok, set()]
                    self.detected_phrase_dict[phrase][0] += 1
                    self.detected_phrase_dict[phrase][4].add(doc_id)
                    collector, prev_tok, next_tok = [], None, None
                
    def get_stat(self):
        for k, v in sorted(self.detected_phrase_dict.items(), key=lambda item: item[1][0], reverse=True):
            if self.DEBUG == 1:
                print(f"{v[0]:>5}\t{v[1] if v[1] else 'None':30}\t{k:30}\t{v[3] if v[3] else 'None' :30}\t{v[2]}")
            elif self.DEBUG >= 2:
                print(f"{v[0]:>5}\t{v[1] if v[1] else 'None':30}\t{k:30}\t{v[3] if v[3] else 'None' :30}\t{v[2]}\t{v[4]}")
