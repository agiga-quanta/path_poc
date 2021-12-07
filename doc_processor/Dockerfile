####################
# set base image (host OS)
#
FROM python:3.8-slim

####################
# Complete installation
# - set the working directory in the container
# - copy the content of the local src directory to the working directory
# - install required Python packages
#
WORKDIR /
COPY src/ .
COPY requirements.txt ./
RUN pip3 install -r /requirements.txt

####################
# Start the app
#
ENTRYPOINT ["python", "doc_process.py"]
