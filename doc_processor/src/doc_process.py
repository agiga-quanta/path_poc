__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from json import dump
from math import log
from os import listdir
from os.path import isfile, join
import sys
from bs4 import BeautifulSoup
from config_handler import ConfigHandler
from header_cleaner import HeaderCleaner
from section_splitter import SectionSplitter
from proponent_process import ProponentProcessor
from location_process import LocationProcessor
from description_process import DescriptionProcessor
from condition_process import ConditionProcessor
from corenlp_process import CoreNLPProcessor
from nlp_process import NLPProcessor
from doc_summarize import DocSummarizer


def print_usage():
    print("""Usage example:
        Note that file(s) must be in a pre-configured directory (docker_compose.yml, doc_processor service, input/ volume).
        1/ For a single file:
            docker-compose run --rm doc_processor 11-HCAA-CA4-01139_Authorization.xhtml
        2/ For all files:
            docker-compose run --rm doc_processor
    """)


if __name__ == '__main__':
    ####################
    # Reading configuration from given file in relative path
    config = ConfigHandler('conf/dp.ini')
    # html_path = 'data/xhtml'
    # json_path = 'data/json'
    # nlp_path = 'data/nlp'
    html_path = config.get_config_option('content', 'html_path')
    json_path = config.get_config_option('content', 'json_path')
    nlp_path = config.get_config_option('content', 'nlp_path')
    html_files = sorted([f for f in listdir(html_path) if isfile(join(html_path, f)) and f.endswith('.xhtml') ])

    hdr_cleaner = HeaderCleaner(config)
    sec_splitter = SectionSplitter(config)
    prp_processor = ProponentProcessor(config)
    loc_processor = LocationProcessor(config)
    des_processor = DescriptionProcessor(config)
    con_processor = ConditionProcessor(config)
    corenlp_processor = CoreNLPProcessor(config)
    nlp_processor = NLPProcessor(config)
    doc_summarizer = DocSummarizer(config)

    start, number = None, None
    if len(sys.argv) == 3:
        try:
            number = int(sys.argv[1])
            start = int(sys.argv[2])
        except Exception:
            pass
    elif len(sys.argv) == 2:
        for count in range(0, len(html_files)):
            if html_files[count].endswith(sys.argv[1]):
                start, number = count, 1
                break
    else:
        start, number = 0, len(html_files)
    
    if start == None:
        print_usage()
        exit(1)
    
    adoc_dict, aent_dict, apos_dict = dict(), dict(), dict()
    for count in range(start, start+number):
        file_name = html_files[count]
        print('[%3d] >>>>> %s -----' % (count, file_name))

        with open(join(html_path, file_name)) as ifile:
            soup = BeautifulSoup(ifile.read(), 'html.parser')
            body = soup.body
            pages = body.find_all('div', {'class': 'page'})

            t_list = []
            for page in pages:
                p_list = page.find_all('p')
                t_list.extend(hdr_cleaner.process([p_list[i].text for i in range(len(p_list))]))

            doc = dict()
            info = hdr_cleaner.get_info()
            doc['header'] = info
            sections = sec_splitter.split(t_list)
            doc['proponent'] = prp_processor.extract(sections['proponent']['t'], corenlp_processor)
            doc['location'] = loc_processor.extract(sections['location']['t'], corenlp_processor)
            doc['description'] = des_processor.extract(sections['description']['t'], corenlp_processor)
            doc['conditions'] = con_processor.extract(sections['conditions']['t'], corenlp_processor)

            doc_id = file_name[:file_name.find('.')]
            with open(join(json_path, doc_id + '.json'), 'wt') as ofile:
                dump(doc, ofile)

            sent_list, ent_dict, pos_dict, info_dict = nlp_processor.process(doc)
            adoc_dict[doc_id] = { 'sen': sent_list, 'ent': ent_dict, 'pos': pos_dict, **info_dict }
            for c, e in ent_dict.items():
                if c not in aent_dict:
                    aent_dict[c] = {'df': set(), **e}
                aent_dict[c]['df'].add(doc_id)
            for c, p in pos_dict.items():
                if c not in apos_dict:
                    apos_dict[c] = {'df': set(), **p}
                apos_dict[c]['df'].add(doc_id)

        print('[%3d] <<<<< %s -----\n' % (count, file_name))

        hdr_cleaner.reset()
        count += 1

    doc_summarizer.compute_tf_idf(number, aent_dict, apos_dict, adoc_dict)

    for doc_id, doc_dict in adoc_dict.items():
        print(f"Summarizing {doc_id} ...")
        with open(join(nlp_path, doc_id + '-NLP.json'), 'wt') as ofile:
            dump(doc_dict, ofile)
        doc_summarizer.generate_summary(doc_id, doc_dict)
        doc_summarizer.generate_wordcloud(doc_id, doc_dict)
