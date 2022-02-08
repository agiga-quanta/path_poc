# -*- coding: utf-8 -*-
from os import getpid, kill
import signal
import traceback
import re

from bottle import BaseRequest, hook, request, response, route, run
from json import dumps, loads

from nltk.stem.snowball import EnglishStemmer

BaseRequest.MEMFILE_MAX = 102400 * 1000
stemmer = EnglishStemmer()


CROSS_ORIGIN_RESOURCE_SHARING_HEADERS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'PUT, GET, POST, DELETE, OPTIONS',
    'Access-Control-Allow-Headers':
        'Origin, Accept, Content-Type, X-Requested-With, X-CSRF-Token',
}

@hook('after_request')
def webapp_enable_cors():
    response.headers.update(CROSS_ORIGIN_RESOURCE_SHARING_HEADERS)


@route('/shutdown', method=['GET'])
def webapp_shutdown():
    kill(getpid(), signal.SIGINT)


@route('/', method='GET')
def webapp_info():
    return {'status': 'NLTK web app is running ...'}


@route('/stem', method='POST')
def process():
    try:
        res_json = loads(request.body.read().decode('utf-8'))
        if res_json and 'sentences' in res_json:
            for s in res_json['sentences']:
                if not s:
                    continue
                for t in s['tokens']:
                    t['s'] = stemmer.stem(t['lemma'])
        return dumps(res_json)

    except Exception:
        print(traceback.print_exc())
        return dumps(['%s' % traceback.print_exc()])
    
if __name__ == '__main__':

    try:
        run(
            host='0.0.0.0',
            port=6543,
            server='waitress',
            threads=4,
        )
    except KeyboardInterrupt:
        pass
