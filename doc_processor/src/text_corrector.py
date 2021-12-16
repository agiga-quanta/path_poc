__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from regex_process import init_ops


class TextCorrector(object):

    def __init__(self, config):
        self.CORRECTORS = init_ops(config.get_eval_option('text_corrector', 'correctors'))
        self.PAGE_NO = init_ops(config.get_eval_option('text_corrector', 'page_no'))
        self.DEBUG = int(config.get_config_option('text_corrector', 'debug'))

    def process(self, doc_pages):
        paragraph_list = []
        for page in doc_pages:
            for paragraph in page:
                for regex in self.CORRECTORS:
                    paragraph = regex['func'](regex, paragraph)
                paragraph_list.append(paragraph)
            
        doc_text = ''.join(paragraph_list)
        if self.DEBUG == 3:
            print('CORRECTED -----\n%s\n----- CORRECTED' % doc_text)

        return doc_text
