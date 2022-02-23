FROM alpine:3.10 as builder

RUN apk update && \
    apk add git wget openjdk8-jre-base py2-pip py2-curl && \
    pip install setuptools

# install grepurl script to retrieve the most current download URL of CoreNLP
WORKDIR /opt
RUN git clone https://github.com/arne-cl/grepurl.git
WORKDIR /opt/grepurl
RUN python setup.py install

# install latest CoreNLP release
WORKDIR /opt
RUN wget https://nlp.stanford.edu/software/stanford-corenlp-latest.zip && \
    unzip stanford-corenlp-latest.zip && \
    mv $(ls -d stanford-corenlp-*/) corenlp && rm *.zip

# install latest English language model
#
# Docker can't store the result of a RUN command in an ENV, so we'll have
# to use this workaround.
# This command get's the first model file (at least for English there are two)
# and extracts its property file.
WORKDIR /opt/corenlp
RUN wget $(grepurl -r 'english.*jar$' -a http://stanfordnlp.github.io/CoreNLP | head -n 1)

# only keep the things we need to run and test CoreNLP
FROM alpine:3.10

RUN apk update && apk add openjdk8-jre-base py3-pip && \
    pip3 install pytest pexpect requests

WORKDIR /opt/corenlp
COPY --from=builder /opt/corenlp .

ENV JAVA_XMX 8g
ENV ANNOTATORS tokenize,ssplit,pos,lemma,ner,parse
ENV REGEXNER /conf/regexner.mappings
ENV TIMEOUT_MILLISECONDS 300000
ENV PARSE_THREADS 16

ENV PORT 9000

EXPOSE $PORT

CMD java -Xmx$JAVA_XMX -cp "*" edu.stanford.nlp.pipeline.StanfordCoreNLPServer -annotators "$ANNOTATORS" -port $PORT -timeout $TIMEOUT_MILLISECONDS -ner.additional.regexner.mapping $REGEXNER -parse.nthreads $PARSE_THREADS
