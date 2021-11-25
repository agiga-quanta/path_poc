__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.1.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


import json
from os import listdir
from os.path import isfile, join
import sys

import stanza

from config_handler import ConfigHandler
from post_nlp import PostProcessor

if __name__ == '__main__':
    ####################
    # Reading configuration from given file in relative path
    config = ConfigHandler('conf/nlp.ini')

    ####################
    # Get full names (including path) of all text files in the given path
    file_path = config.get_config_option('content', 'file_path')
    json_path = config.get_config_option('content', 'json_path')
    text_files = [f for f in listdir(file_path) if isfile(join(file_path, f)) and f.endswith('.txt') ]

    ####################
    # Create an instance of the post processor
    post_processor = PostProcessor(config)

    ####################
    # Start `stanza`:
    # - obtain the language string
    # - (optional) uncomment if the language's model was not pre-downloaded
    # - creates a `stanza` NLP processing pipeline, namely `nlp`
    language = config.get_config_option('stanza', 'language')
    # stanza.download(language)
    nlp = stanza.Pipeline(language)

    for file_name in text_files:
        with open(join(file_path, file_name)) as ifile:
            lines = ifile.readlines()
        json_content = post_processor.process(nlp('\n'.join(lines)))

        with open(join(json_path, file_name[:file_name.find('.')] + '.json'), 'wt') as ofile:
            json.dump(json_content, ofile)
