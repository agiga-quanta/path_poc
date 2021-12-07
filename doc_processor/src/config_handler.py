__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2018"
__version__ = "1.0.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Production"


from ast import literal_eval
from configparser import ConfigParser, ExtendedInterpolation


class ConfigHandler(object):

    def __init__(self, config_filename):
        if config_filename is None:
            raise ValueError('Invalid config %s' % config_filename)

        self.config_filename = config_filename
        self.parser = self.__load()

    def __load(self):
        parser = ConfigParser(interpolation=ExtendedInterpolation())

        try:
            parser.read(self.config_filename, encoding='utf-8')
            return parser

        except Exception as ex:
            raise ValueError('Cannot read config %s, %s' % (
                self.config_filename, ex.__traceback__
            ))

    def get_section(self, section_name):
        if section_name is None or section_name not in self.parser:
            return None

        return self.parser[section_name]

    def get_config_option(self, section_name, option_name):
        section = self.get_section(section_name)

        if section is None:
            return None

        if option_name is None or option_name not in section:
            return None

        return section[option_name]

    def get_eval_option(self, section_name, option_name):
        option = self.get_config_option(section_name, option_name)

        if option is None:
            return None

        return literal_eval(option)

    def reload(self):
        self.parser = self.__load()
