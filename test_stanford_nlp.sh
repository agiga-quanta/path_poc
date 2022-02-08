#!/bin/sh

curl -d "@test/terms.txt" -H "Content-Type: plain/text" -X POST http://localhost:9000/ > test/terms_nlp.json
