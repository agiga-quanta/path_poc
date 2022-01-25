__author__ = "Nghia Doan"
__company__ = "Agiga Quanta Inc."
__copyright__ = "Copyright 2021"
__version__ = "0.2.0"
__maintainer__ = "Nghia Doan"
__email__ = "nghia71@gmail.com"
__status__ = "Development"


from wordcloud import WordCloud


class WorldCouldGenerator(object):

    def __init__(self, config):
        self.imag_opts = [
            { 'path': '', 'colormap': 'Dark2', 'background_color': 'white', 'width': 1600, 'height': 1200 },
            # { 'path': '/opt_1', 'colormap': 'tab10', 'background_color': 'white', 'width': 1600, 'height': 1200 },        # 'tab10'
            # { 'path': '/opt_2', 'colormap': 'copper', 'background_color': 'white', 'width': 1600, 'height': 1200 },       # 'copper'
            # { 'path': '/default', 'colormap': 'viridis', 'background_color': 'black', 'width': 1600, 'height': 1200 },    # 'black'
        ]

    def generate_wordcloud(self, doc_id, freq_dict):
        for _, opt in self.imag_opts.items():
            cloud = WordCloud(
                colormap=opt['colormap'],
                background_color=opt['background_color'],
                width=opt['width'],
                height=opt['height']
            )
            cloud.generate_from_frequencies(freq_dict)
            image_file = '%s%s/%s.png' % (self.imag_path, opt['path'], doc_id) 
            cloud.to_file(image_file)
