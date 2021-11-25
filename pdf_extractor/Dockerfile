FROM alpine:3.15

#__author__ = "Nghia Doan"
#__company__ = "Agiga Quanta Inc."
#__copyright__ = "Copyright 2021"
#__version__ = "0.1.0"
#__maintainer__ = "Nghia Doan"
#__email__ = "nghia71@gmail.com"
#__status__ = "Development"

#
# Install all required dependencies.
#

RUN apk add --update curl && \
    rm -rf /var/cache/apk/*

WORKDIR /
COPY extract_pdf.sh .

ENTRYPOINT [ "/extract_pdf.sh" ]