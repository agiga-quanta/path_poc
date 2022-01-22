from json import dump
from os import listdir
from os.path import isfile, join
import sys
from bs4 import BeautifulSoup
from config_handler import ConfigHandler
from condition_extractor import ConditionExtractor
from description_extractor import DescriptionExtractor
from header_extractor import HeaderExtractor
from location_extractor import LocationExtractor
from nlp_processor import NLPProcessor
from pos_processor import POSProcessor
from proponent_extractor import ProponentExtractor
from section_splitter import SectionSplitter
from spell_checker import SpellChecker
from text_corrector import TextCorrector


if __name__ == '__main__':
    config = ConfigHandler('conf/dp.ini')
    json_path = config.get_config_option('doc_processor', 'json_path')
    html_path = config.get_config_option('doc_processor', 'html_path')
    html_files = sorted([f for f in listdir(html_path) if isfile(join(html_path, f)) and f.endswith('.xhtml') ])

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
        exit(1)

    nlp_processor = NLPProcessor(config)

    txt_corrector = TextCorrector(config)
    hdr_extractor = HeaderExtractor(config)
    sec_splitter = SectionSplitter(config)
    prp_extractor = ProponentExtractor(config)
    loc_extractor = LocationExtractor(config)
    des_extractor = DescriptionExtractor(config)
    con_extractor = ConditionExtractor(config)
    spl_checker = SpellChecker(config)
    pos_processor = POSProcessor(config)

    for count in range(start, start+number):
        file_name = html_files[count]
        doc_id = file_name[:file_name.find('.')]
        print('[%3d] >>>>> %s -----' % (count, file_name))

        with open(join(html_path, file_name)) as ifile:
            soup = BeautifulSoup(ifile.read(), 'html.parser')
            body = soup.body
            pages = body.find_all('div', {'class': 'page'})

            t_list = []
            for page in pages:
                p_list = []
                f_list = page.find_all('p')
                for i in range(0, len(f_list)):
                    p_text = f_list[i].text
                    if not p_text:
                        continue
                    if i == len(f_list) - 2:
                        # print(f"{i} [{p_text}]")
                        if any([regex['func'](regex, p_text) is not None for regex in txt_corrector.PAGE_NO]):
                            # print('---')
                            continue
                    p_list.append(p_text)
                t_list.append(p_list)

            doc = dict()
            doc_text = txt_corrector.process(t_list)
            doc['headers'], doc_text = hdr_extractor.process(doc_text)
            sections = sec_splitter.split(doc_text)
            doc['proponent'] = prp_extractor.extract(sections['proponent']['t'], nlp_processor, spl_checker, doc_id)
            doc['location'] = loc_extractor.extract(sections['location']['t'], doc_id)
            doc['description'] = des_extractor.extract(sections['description']['t'], nlp_processor, spl_checker, pos_processor, doc_id)
            doc['conditions'] = con_extractor.extract(sections['conditions']['t'], nlp_processor, spl_checker, pos_processor, doc_id)

        with open(join(json_path, doc_id + '.json'), 'wt') as ofile:
            dump(doc, ofile)

        print('[%3d] <<<<< %s -----\n' % (count, file_name))

    spl_checker.get_stat()
