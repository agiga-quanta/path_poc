# path_poc
Proof of Concept (POC) for mining Program Activity Tracking for Habitat (PATH)

## Installation for Mac OS X

### Install required software packages

#### Docker Desktop 

Visit [Get Started with Docker](https://www.docker.com/get-started) and download Docker Desktop depending on which CPU version (Intel or Apple chip). 

Run the **Docker.app** to install. Run the app after installation. Once it started, open the *Preferences* to set configuration. You will need:
* CPUs: at least half the cores that you have, for example 4 (if you have 8.)
* Memory: at least 12 GB is required (4GB for Neo4j, 8GB for Stanford NLP)
* Swap: 2 GB
* Disk image size: 40 GB

#### Homebrew (package manager)

Visit [Homebrew](https://brew.sh), copy the link to run its installation at *Install Homebrew*.

You can also use this one below, paste this in a macOS Terminal and hit *Enter*:

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Once done, update and upgrade brew:

    brew update
    brew upgrade

##### Apple XCode Command Line Tools

Note: this is needed only if 
- you have never installed the Command Line Tools.
- during upgrading brew, you see "*Error*: Your Command Line Tools are too outdated"

First, try

    softwareupdate --all --install --force

If that doesn't show you any updates, run:
    
    sudo rm -rf /Library/Developer/CommandLineTools

then enter your password if required, then wait until the software is downloaded, installed, then run:

    sudo xcode-select --install

and rerun

    softwareupdate --all --install --force

and wait until the Command Line Tools are downloaded and installed. Then rerun:

    brew update
    brew upgrade

and wait until they finish.

#### Install git
You will need git to automatically download or update the git repository for the source code of **path_poc** from [Github][https://github.com]

    brew install git

#### Install curl
You will need curl to automatically download binary data from [Dropbox](https://www.dropbox.com)

    brew install curl

### Clone the source code repository and binary data

#### Clone path_poc repository from Github
Go to the directory where you will use it. For example in your home directory,
create a folder *work*,

    cd
    mkdir work
    cd work

Then run:

    git clone https://github.com/agiga-quanta/path_poc.git
    cd path_poc

#### Download pre-processed binary data (xhtml, json)
Create a *data* sub-folder,

    mkdir data

Download with *curl* the binary **xhtml.zip**, which contains all content previously *extracted* from pdf files and **manually fixed**.

    curl -L -o data/xhtml.zip "https://www.dropbox.com/s/b4cdffteuf111iw/xhtml.zip?dl=1"
    cd data
    unzip xhtml.zip
    cd ..

Download with *curl* the binary **jzon.zip**, which contains all *natural language processed* content from *xhtml* files into *json* files.

    curl -L -o data/json.zip "https://www.dropbox.com/s/2rse6896qvjp1f0/json.zip?dl=1"    
    cd data
    unzip xhtml.zip
    cd ..

#### If you have already previous versions of some docker images and containers
Clean them up by

    docker system prune -a

Type *Y* when it asks if you want to delete those. Then run:

    docker system info

Check if you see a snipet like below, meaning you have 7 images and nothing else.

    Server:
        Containers: 0
        Running: 0
        Paused: 0
        Stopped: 0
    Images: 7

#### Get the docker images
Make sure that you are inside the *path_poc* folder:

    pwd

You should see something as below, where *<YOURNAME>* would be your login,

    /Users/<YOURNAME>/work/path_poc

Then run,

    docker-compose pull

Wait until it is finish, then run:

    docker image ls

You should see something as below,

    REPOSITORY                  TAG       IMAGE ID       CREATED        SIZE
    agigaquanta/pdf_extractor   1.0.0     e9b56ff77329   5 days ago     7.69MB
    agigaquanta/nltk_nlp        1.0.0     834a634a4304   5 days ago     147MB
    agigaquanta/doc_processor   1.0.0     bc121f6a198f   6 days ago     371MB
    agigaquanta/stanford_nlp    1.0.0     b8dd8981978f   6 days ago     1.09GB
    nielsdejong/neodash         latest    185583d341cc   2 weeks ago    37.2MB
    neo4j                       4.4.3     5e4d45f69541   2 weeks ago    579MB
    apache/tika                 2.1.0     0546ced95220   3 months ago   428MB

### Processing pipelines

#### Extracting data from pdf files
Note that you don't have to do this since this already been done and the content of all processed files is packaged inside *xhtml.zip*
However if you want to do it again, follow the instructions below.

**WARNING** Following the below instructions will alter the content of the files in the *data/xhtml* sub-folder.
You can restore them to the original pre-processed and manually fixed version by extracting the *xhtml.zip* as show in a section above.

First create a sub-folder under data,

    cd data
    mkdir pdf

You need to copy all 248 pdf files into *data/pdf/*, then get [Apache Tika](https://tika.apache.org) *tika* docker up and running (in the background with the *-d* flag)

    docker-compose up -d tika

Then run the *pdf_extractor* docker

    docker-compose up pdf_extractor

Stop the *tika* docker to save memory,

    docker-compose stop tika

#### Run the extracted data through a Stanford CoreNLP pipeline, with Wordnet dictionary
Note that you don't have to do this since this already been done and the content of all processed files is packaged inside *json.zip*
However if you want to do it again, follow the instructions below.

**WARNING** Following the below instructions will alter the content of the files in the *data/json* sub-folder.
You can restore them to the original pre-processed and manually fixed version by extracting the *json.zip* as show in a section above.

Get [Stanford CoreNLP](https://nlp.stanford.edu) *stanford_nlp* and [NLTK](https://www.nltk.org) *nltk_nlp* dockers up and running (both in the background with the *-d* flag)

    docker-compose up -d stanford_nlp nltk_nlp

Then run the *doc_processor* docker

    docker-compose up doc_processor

This will process 248 **.xhtml* files into **.json* files.

#### Using the *Standford CoreNLP with custom NERs* docker
*Note:* you can check which dockers are running by:

    docker-compose ps

If *stanford_nlp* and *nltk_nlp* are already running, then start the *neo4j* docker:

    docker-compose up -d neo4j

If none of them are running, then run:

    docker-compose up -d stanford_nlp nltk_nlp neo4j

Now, open a browser and point at [Stanford CoreNLP with custom NERs](http://localhost:9000), you will see the interface to access and run some queries with the Stanford CoreNLP with custom named-entities are defined. You can also manually type into the address box:

    http://localhost:9000

In the **- Annotations -** dropbox, select *part-of-speech*, *lemmas*, *named entities*, *named entities (regexner)*, *constituency parse* in **this order**, copy and paste the following paragraph into the **- Text to annotate -** box.

    Scale and description of offsetting measures: Offsetting shall be carried out in accordance with the description below and as set out in the Proponent\u2019s Offsetting Plan and shall be undertaken at the Millhaven terminal site, the Stella terminal site, and Clark Island in Hay Bay, Lake Ontario.

It would take sometime to load the machined-learned (ML) datasets for the first run (or anytime when you change the set of annotators). 
You now can see how the words are isolated, lemmatized, part-of-speech captured, named entities are recognized, and the tree of the constituency parsing result.

#### Import json data into Neo4j database
Now, open a browser and point at [Neo4j](http://localhost:7474), you will see the interface to access and run some queries with Neo4j. You can also manually type into the address box:

    http://localhost:7474

If it is the first time you access Neo4j from the browser, you will see a form **Connect to Neo4j**, type *neo4j* into the *Username* edit box,
and *path_poc* (all small caps and an underscore character) into the *Password* edit box, then click *Connect* button.

Copy and paste the following query into the edit box started with the prompt **neo4j$** to test if the database is ready

    CALL dbms.components()
        YIELD name, versions, edition
    UNWIND versions AS version
    RETURN name, version, edition;

You can click the **blue arrow** or press Ctrl+Enter (after copy the query into the **neo4j$** prompt and your mouse course is still inside that box.) If you see

    | name | version        | edition |             |
    |------|----------------|---------|-------------|
    | 1    | "Neo4j Kernel" | "4.4.3" | "community" |



