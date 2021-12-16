__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from json import load
from os import listdir
from os.path import isfile, join
import re
import sys
from config_handler import ConfigHandler
from excel_exporter import ExcelExporter
from nlp_processor import NLPProcessor
from pos_processor import POSProcessor


if __name__ == '__main__':
    config = ConfigHandler('conf/pos.ini')
    json_path = config.get_config_option('case_processor', 'json_path')
    all_json_files, idx = [], 0
    for f in sorted(listdir(json_path)):
        if isfile(join(json_path, f)) and f.endswith('.json'):
            all_json_files.append([idx, f])
            idx += 1

    start, number = None, None
    try:
        if len(sys.argv) == 3:
            number = int(sys.argv[1])
            start = int(sys.argv[2])
            assert number <= len(all_json_files) and start >= 0 and start < number
            json_files = [ all_json_files[i] for i in range(start, start+number) ]
        
        elif len(sys.argv) == 2:
            if sys.argv[1].endswith('.json') and isfile(join(json_path, sys.argv[1])):
                for i in range(0, len(all_json_files)):
                    if all_json_files[i][1] == sys.argv[1]:
                        json_files = [ all_json_files[i] ]
                        break
            
            else:
                json_files = []
                file_list = sys.argv[1].split(';')
                print(file_list)
                for i in range (0, len(all_json_files)):
                    if any([f in all_json_files[i][1] for f in file_list]):
                        json_files.append(all_json_files[i])

        else:
            json_files = all_json_files

    except Exception:
        exit(1)

    nlp_processor = NLPProcessor(config)
    pos_processor = POSProcessor(config)
    exl_exporter = ExcelExporter(config)
    
    extractors = config.get_eval_option('case_processor', 'extractors')
    for name, extractor in extractors.items():
        grammar = re.compile(extractor['grammar'])
        collect = re.compile(extractor['collect'])
        kw_dict = dict()
        if 'phrases' in extractor:        
            for phrase in extractor['phrases']:
                nlp_phrase = nlp_processor.process(phrase)
                for nlp_sent in nlp_phrase['sentences']:
                    pos_dict = pos_processor.collect_phrases(nlp_sent['tokens'], grammar, collect)
                    for phr, phr_dict in pos_dict.items():
                        kw_dict[phr] = [
                            set(w['t'] for w in phr_dict['w']), 
                            set(w['t'] for w in phr_dict['w'] if w['p'].startswith('NN') or w['p'].startswith('VB'))
                        ]
        extractor.update({ 'grammar': grammar, 'collect': collect, 'kw_dict': kw_dict })
        # print(name)
        # for k, v in extractor['kw_dict'].items():
        #     print(k, v)

    lookup, reason, footprint, impact = [extractors[n] for n in ['lookup', 'reason', 'footprint', 'impact']]

    # sentence = 'The destruction of 238 m2 of average fish habitat due to infilling of the existing channel associated with construction of in-water piers and the western abutment.'
    # summ_desc, summ_cond = dict(), dict() 

    doc_dict = dict()
    for count, file_name in json_files:
        doc_id = file_name[:file_name.find('.')]
        path_id = doc_id[:doc_id.find('_')]

        print('[%3d] >>>>> %s -----' % (count, file_name))
        with open(join(json_path, file_name)) as ifile:
            json_doc = load(ifile)

            desc_list = []
            for name, element in json_doc['description'].items():
                if name.startswith('proj') or name.startswith('auth'):
                    continue

                nlp_doc = element['nlp']
                for nlp_sent in nlp_doc['sentences']:
                    sent_dict = dict()
                    sent_dict['sent'] = ' '.join(t['originalText'] for t in nlp_sent['tokens'])
                    # print(f"\n[{' '.join(t['originalText'] for t in nlp_sent['tokens'])}]")
                    for n in ['lookup', 'reason', 'footprint', 'impact']:
                        extractor = extractors[n]
                        extractor['pos'] = pos_processor.collect_phrases(nlp_sent['tokens'],  extractor['grammar'], extractor['collect'])

                    found_lookup, found_impact = False, False
                    for phr, phr_dict in lookup['pos'].items():
                        n_set = set(w['t'].lower() for w in phr_dict['w'])
                        found_full_lookup, found_part_lookup = False, False
                        for kp, ks in lookup['kw_dict'].items():
                            fks, pks = ks
                            # print(n_set, fks, pks, n_set.issuperset(pks))
                            if n_set.issuperset(fks):
                                if 'impact' not in sent_dict:
                                    sent_dict['impact'] = dict()
                                if phr not in sent_dict['impact']:
                                    sent_dict['impact'][phr] = set()
                                sent_dict['impact'][phr].add(' '.join(fks))
                                print(f"--- Impact Type (F) --- [{phr}] ({n_set} <-- {fks})")
                                found_full_lookup, found_lookup = True, True
                            if not found_full_lookup and n_set.issuperset(pks):
                                if 'impact' not in sent_dict:
                                    sent_dict['impact'] = dict()
                                if phr not in sent_dict['impact']:
                                    sent_dict['impact'][phr] = set()
                                sent_dict['impact'][phr].add(' '.join(pks))
                                print(f"--- Impact Type (P) --- [{phr}] ({n_set} <-- {pks})")
                                found_part_lookup, found_lookup = True, True

                    if found_lookup:
                        for phr, phr_dict in footprint['pos'].items():
                            wf = phr_dict['w'][0]['o']
                            wr = [w['o'] for w in phr_dict['w'][1:]]
                            if 'footprint' not in sent_dict:
                                sent_dict['footprint'] = dict()
                            sent_dict['footprint'][phr] = [wf, wr]
                            print(f"--- Footprint --- [{wf}] [{wr}]")

                        for phr, phr_dict in impact['pos'].items():
                            n_set = set(w['t'].lower() for w in phr_dict['w'])
                            found_full_impact, found_part_impact = False, False
                            for kp, ks in reason['kw_dict'].items():
                                fks, pks = ks
                                # print(n_set, fks, pks, n_set.issuperset(pks))
                                if n_set.issuperset(fks):
                                # if n_set.intersection(ks):
                                    if 'reason' not in sent_dict:
                                        sent_dict['reason'] = dict()
                                    if phr not in sent_dict['reason']:
                                        sent_dict['reason'][phr] = set()
                                    sent_dict['reason'][phr].add(' '.join(fks))
                                    print(f"--- Key Impact (F) --- [{' '.join([w['o'] for w in phr_dict['w']])}] ({n_set} <--- {fks})")
                                    found_full_impact, found_impact = True, True
                                if not found_full_impact and n_set.issuperset(pks):
                                # if n_set.intersection(ks):
                                    if 'reason' not in sent_dict:
                                        sent_dict['reason'] = dict()
                                    if phr not in sent_dict['reason']:
                                        sent_dict['reason'][phr] = set()
                                    sent_dict['reason'][phr].add(' '.join(pks))
                                    print(f"--- Key Impact (P) --- [{' '.join([w['o'] for w in phr_dict['w']])}] ({n_set} <--- {pks})")
                                    found_part_impact, found_impact = True, True

                    if found_lookup:
                        for k, v in sent_dict.items():
                            print(k, v)
                        print(f"--- >>> --- {' '.join(t['originalText'] for t in nlp_sent['tokens'])} --- <<< ---")
                        desc_list.append(sent_dict)

            doc_dict[path_id] = [json_doc['proponent'], json_doc['location'], desc_list]

        print('[%3d] <<<<< %s -----\n' % (count, file_name))

    exl_exporter.export(doc_dict, ',\n'.join(p for p in lookup['phrases']), ',\n'.join(p for p in reason['phrases']), 'exercise-1.xlsx')

    #         for name, element in json_doc['description'].items():
    #             hdr = 'padding'
    #             if 'k' in element:
    #                 hdr = element['k'].replace('\n', ' ')
    #             if hdr not in summ_desc:
    #                 summ_desc[hdr] = [0, set()]
    #             summ_desc[hdr][0] += 1
    #             summ_desc[hdr][1].add(name)

    #         for bullet, content in json_doc['conditions']:
    #             if len(bullet.split('.')) <= 4:
    #                 hdr = content['t'].replace('\n', ' ')
    #                 if hdr not in summ_cond:
    #                     summ_cond[hdr] = 0
    #                 summ_cond[hdr] += 1

    #     print('[%3d] <<<<< %s -----\n' % (count, file_name))

    # for k, v in sorted(summ_desc.items(), key=lambda item: (list(item[1][1]), item[1][0]), reverse=True):
    #     if v[0] > 1:
    #         print(f"{v[0]:3}\t{v[1]}\t{k}")

    # for k, v in sorted(summ_cond.items(), key=lambda item: item[1], reverse=True):
    #     if v > 1:
    #         print(f"{v:3}\t{k} ")