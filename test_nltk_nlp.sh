#!/bin/sh

curl -d "@test/terms_nlp.json" -H "Content-Type: application/json" -X POST http://localhost:7000/stem > test/terms_stem.json
