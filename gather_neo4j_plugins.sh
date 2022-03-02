#!/bin/bash

####################
# Download for neo4j into plugins/ directory following libraries
# - neo4j-apoc-procedures
# - graph-data-science
####################

mkdir -p neo4j/data neo4j/logs neo4j/plugins

NEO4J_VERSION=4.4.3
GDS_LIB_VERSION=1.8.2
APOC_LIB_VERSION=4.4.0.2
GITHUB_GDS_URI=https://github.com/neo4j/graph-data-science/releases/download
GITHUB_APOC_URI=https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download

NEO4J_GDS_URI=${GITHUB_GDS_URI}/${GDS_LIB_VERSION}/neo4j-graph-data-science-${GDS_LIB_VERSION}.jar
NEO4J_APOC_URI=${GITHUB_APOC_URI}/${APOC_LIB_VERSION}/apoc-${APOC_LIB_VERSION}-all.jar

curl -C- --progress-bar --location ${NEO4J_GDS_URI} --output neo4j/plugins/neo4j-graph-data-science-${GDS_LIB_VERSION}.jar
curl -C- --progress-bar --location ${NEO4J_APOC_URI} --output neo4j/plugins/apoc-${APOC_LIB_VERSION}-all.jar
echo 'Done.'
