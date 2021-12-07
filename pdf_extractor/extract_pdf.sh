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
    echo "1/ For a single file:"
    echo "  docker-compose run --rm pdf_extractor <html|json|text> http://tika:9998/tika 11-HCAA-CA4-01139_Authorization.pdf"
    echo "2/ For all files:"
    echo "  docker-compose run --rm pdf_extractor"
    echo ""
}

OUTPUT_FORMAT=text/html
TIKA_SERVER_URL=http://tika:9998/tika
INPUT_FILE=
EXTENSION=xhtml
INPUT_DIR=/pdf
OUTPUT_DIR=/xhtml

if [ "$#" -ne 0 ] && [ "$#" -ne 3 ]; then
    print_usage
fi

if [ "$#" -eq 3 ]; then
    if [ $1 = "text" ]; then
        OUTPUT_FORMAT=text/plain
        EXTENSION=txt
    elif [ $1 = "html" ]; then
        OUTPUT_FORMAT=text/html
        EXTENSION=xhtml
    elif [ $1 = "json" ]; then
        OUTPUT_FORMAT=application/json
        EXTENSION=json
    else
        print_usage()
        exit 1
    fi
    TIKA_SERVER_URL=$2
    INPUT_FILE=$3
fi

echo $OUTPUT_FORMAT $TIKA_SERVER_URL $INPUT_FILE

cd $INPUT_DIR

for file in *.pdf; do
    file_name=`echo "$file" | cut -d'.' -f1`
    if [ "$#" -eq 0 ] || ([ "$#" -eq 3 ] && [ "$file" == *"$INPUT_FILE"* ]); then
        curl -X PUT --data-binary @"$file" -H "Content-type: application/pdf" -H "Accept: $OUTPUT_FORMAT" $TIKA_SERVER_URL > "$OUTPUT_DIR/$file_name.$EXTENSION"
    fi
done

cd ..

echo 'Processing done.'