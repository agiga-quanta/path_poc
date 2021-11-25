#!/bin/sh

#__author__ = "Nghia Doan"
#__company__ = "Agiga Quanta Inc."
#__copyright__ = "Copyright 2021"
#__version__ = "0.1.0"
#__maintainer__ = "Nghia Doan"
#__email__ = "nghia71@gmail.com"
#__status__ = "Development"


OUTPUT_FORMAT=text/plain
TIKA_SERVER_URL=http://tika:9998/tika
EXTENSION=txt

if [ "$#" -gt 1 ]; then
    TIKA_SERVER_URL=$2
fi

if [ "$#" -gt 0 ]; then
    if [ $1 = "text" ]; then
        OUTPUT_FORMAT=text/plain
        EXTENSION=txt
    elif [ $1 = "html" ]; then
        OUTPUT_FORMAT=text/html
        EXTENSION=xhtml
    elif [ $1 = "json" ]; then
        OUTPUT_FORMAT=application/json
        EXTENSION=json
    fi
fi

echo $OUTPUT_FORMAT $TIKA_SERVER_URL

cd input

for file in *.pdf; do
    file_name=`echo "$file" | cut -d'.' -f1`
    curl -X PUT --data-binary @"$file" -H "Content-type: application/pdf" -H "Accept: $OUTPUT_FORMAT" $TIKA_SERVER_URL > "/output/$file_name.$EXTENSION"
done

cd ..

echo 'Processing done.'