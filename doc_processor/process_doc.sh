#!/bin/sh

#__author__ = "Nghia Doan"
#__company__ = "Agiga Quanta Inc."
#__copyright__ = "Copyright 2021"
#__version__ = "0.1.0"
#__maintainer__ = "Nghia Doan"
#__email__ = "nghia71@gmail.com"
#__status__ = "Development"

print_usage() {
    echo "Usage examples:"
    echo "  Note that file(s) must be in a pre-configured directory (docker_compose.yml, pdf_extractor service, input/ volume)."
    echo ""
    echo "1/ For a single file:"
    echo "  docker-compose run --rm doc_processor <file_name>"
    echo ""
    echo "Example: "
    echo "  docker-compose run --rm doc_processor 11-HCAA-CA4-01139_Authorization.xhtml"
    echo ""
    echo "2/ For a number of files:"
    echo "  docker-compose run --rm doc_processor <number_of_files> <start_index>"
    echo ""
    echo "Example: run 1 file from the first (0) one"
    echo "  docker-compose run --rm doc_processor 1 0"
    echo "Example: run 3 files from the third (2) one"
    echo "  docker-compose run --rm doc_processor 3 2"
    echo ""
    echo "Don't forget to prune the images:"
    echo "  docker image prune"
    echo ""
    echo ""
    echo "3/ For all files:"
    echo "  docker-compose up doc_processor"
    echo ""
}

if [ "$#" -eq 1 ] && [ $1 = "-h" ]; then
    print_usage
    exit 0
fi

python doc_processor.py "$@"

echo 'Processing done.'