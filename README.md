# path_poc
Proof of Concept (POC) for mining Program Activity Tracking for Habitat (PATH)

## A. The Project

### A.1 Background

A feasibility study was recently completed to *evaluate automation of the application of domain knowledge for current working process* with the Program Activity Tracking for Habitat (PATH) of Fisheries and Oceans Canada (DFO). The study briefly analyzed current working process, existing data for machine learning, objective of work authorizations. It is concluded that there are opportunities to gain better insights, reduce manual repetitive work, increase performance and accuracy by application of automation, machine learning, and graph network science. 

As a continuation of this work, DFO has conducted Natural Language Processing on a set of 248 PATH files, in order to extract key ideas.  However, the organization of these ideas, and application of the machine learning used in previous projects requires a supervised learning component in order to apply the analysis to future datasets. The purpose of this contract is to conduct a supervised learning exercise to make raw NLP extractions more relevant to type of content that is typically sought from PATH documents.

### A.2 Scope 

#### A.2.1 Milestone 1: Document preparation and processing for NLP analysis

Input:
- 250 cases with all accompanied documents, descriptions, and notes (if any)

Output: 
- Structured text corpora built based on extracted content of 248 cases (for M2, Component 2),
Customizable configuration per document format for processing assistance (for later, related use by DP in M1, Component 1), 
- Documented discrepancies versus preliminary assumptions (for domain experts to adjust content of the 248 cases when repeating M1, Component 1).

Tasks:
- Advise on appropriate mode for making the documents associated with 248 cases accessible, as well as requirements for identifying assumptions about document structures and relationships.
- Conduct preliminary document processing (DP) on assembled documents according to identified standard document structure, content formats and high-level logical relations between documents and their content structure. Filter non-standard documents and update assumptions about relationships.

#### A.2.2 Milestone 2: Supervised learning using domain expertise

Input: 
- Structured text corpora built based on extracted content of 248 cases (from M1, Component 1)
- Improperly classified or extracted content as input back for improving DSD (from M3, Component 1)

Output: 
- A number of ‘Domain Specific Datasets’ (DSD), each contains a sets of domain-specific key phrases, relationships between them (if any), relevancy weights (if applicable), or  external ‘enrichment’ datasets that can be used to complement the structured text corpora (from M1, Component 1),
NLP-extracted, DSD-enriched result set and graph of 250 cases (for M3, Component 1),
- Recommendations for standardizing, collecting, and maintaining a set of DSDs for this project and later use (for both scientists and domain-experts).

Tasks:
- With domain experts to identify which key phrases identified in M1 are relevant, relationships between them as well as other external ‘enrichment’ datasets that can be used to complement the M1 results. These results will comprise the ‘Domain Specific Datasets’ (DSD).
- Iteratively incorporate the DSD into the NLP process to get a more granular, supervised result set and graph.

#### A.2.3 Milestone 3: Scoring and refining of process outputs

Input: 
- NLP-extracted, DSD-enriched result set and graph of 248 cases (from M2, Component 2)
- For each of 248 cases, a set of relevant reference data (as sentences or key phrases), with indicated importance by numeric weights (or other comparable meanings), to be used for quality verification.

Output: 
- Automatic, repeatable evaluation of 248 cases with score for each case,
- Identified improperly classified or extracted content as input back for improving DSD by Milestone 2.

Tasks:
- Work with domain experts to identify a format for reference data to be compared against extracted data and to score the relative importance of extracted sentences or key phrases.
- From M2 results, perform summarization on each of the cases to verify whether the automatically extracted information matches the data which were manually extracted. 
- With the scored results, identify content that was improperly classified or extracted and re-iterate the process from the DSD step to improve the extraction results.

#### A.2.4 Milestone 4: Training and handover
- Provide a walkthrough of the proof-of-concept technology to the assigned staff
- Provide technical advice on deploying to DFO’s cloud-based Azure instance. 

### B. Architecture

#### B.1 Extraction from pdf into xhtml documents

![PDF Extractor with Apache Tika](/img/arch/arch.001.png)

#### B.2 Processs xhtml into json content

![Doc Processor with Stanford CoreNLP, NLTK, and Princeton Wordnet](/img/arch/arch.002.png)

#### B.3 Import json content into neo4j and present via customizable dashboard

![Neo4j Database and neodash visualization app](/img/arch/arch.003.png)

## C. Installation basic software for Windows

### C.1 Pre-requisite

- Operating System: Windows 10, Mac OS X, or Ubuntu (or Linux variants)
- Minimum 16GB RAM, 100 GB free on HDD
- Admin privileges (Windows), sudo users (Mac/Linux)

### C.2 Installing Linux kernel update, Windows Subsystems for Linux (WSL 2), and Docker Desktop

- Run Windows Update: Start > Settings > Windows Update> Check for updates: Windows 10 version 2004 and higher (Build 19041 and higher) or Windows 11 (To check your Windows version and build number, select Windows logo key + R, type winver, select OK) 
- Download and Install Linux kernel update package (https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi) and run it.
- Open a Power Shell, and install Windows Subsystems for Linux (WSL 2) by typing:
wsl —install -d Ubuntu
- Once WSL Ubuntu starts (on  separate Command Prompt window), choose a username and a password (anything you like).
- Download Docker Desktop from https://www.docker.com/products/docker-desktop (likely version 4.4.4 or later) and run it (“Docker Desktop Installer.exe”), follow instructions on https://docs.docker.com/desktop/windows/install/
- From Start Menu, run Docker Desktop

## D. Installation basic software for Mac OS X

### D.1 Install Docker Desktop 

Visit [Get Started with Docker](https://www.docker.com/get-started) and download Docker Desktop depending on which CPU version (Intel or Apple chip). 

Run the **Docker.app** to install. Run the app after installation. Once it started, open the *Preferences* to set configuration. You will need:
* CPUs: at least half the cores that you have, for example 4 (if you have 8.)
* Memory: at least 12 GB is required (4GB for Neo4j, 8GB for Stanford NLP)
* Swap: 2 GB
* Disk image size: 40 GB

### D.2 Homebrew (package manager)

Visit [Homebrew](https://brew.sh), copy the link to run its installation at *Install Homebrew*.

You can also use this one below, paste this in a macOS Terminal and hit *Enter*:

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Once done, update and upgrade brew:

    brew update
    brew upgrade

#### D.2.1 Apple XCode Command Line Tools

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

### D.3. Install git
You will need git to automatically download or update the git repository for the source code of **path_poc** from [Github][https://github.com]

    brew install git

### D.4. Install curl
You will need curl to automatically download binary data from [Dropbox](https://www.dropbox.com)

    brew install curl

## E. Installation project source code and Docker images/container

### E.1 Clone path_poc repository from Github
Go to the directory where you will use it. For example in your home directory,
create a folder *work*,

    cd
    mkdir work
    cd work

Then run:

    git clone https://github.com/agiga-quanta/path_poc.git
    cd path_poc

### E.2 Download pre-processed binary data (xhtml, json)
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
    unzip json.zip
    cd ..

### E.3 If you have already previous versions of some docker images and containers
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

### E.4 Get the docker images
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

### E.5 Get the Neo4j plugins
We need the [Neo4j APOC Library](https://neo4j.com/developer/neo4j-apoc/) and the [Graph Data Science](https://neo4j.com/developer/graph-data-science/), simply run:

    ./gather_neo4j_plugins.sh

## F. Processing pipelines

### F.1 Extracting data from pdf files
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

### F.2 Run the extracted data through a Stanford CoreNLP pipeline, with Wordnet dictionary
Note that you don't have to do this since this already been done and the content of all processed files is packaged inside *json.zip*
However if you want to do it again, follow the instructions below.

**WARNING** Following the below instructions will alter the content of the files in the *data/json* sub-folder.
You can restore them to the original pre-processed and manually fixed version by extracting the *json.zip* as show in a section above.

Get [Stanford CoreNLP](https://nlp.stanford.edu) *stanford_nlp* and [NLTK](https://www.nltk.org) *nltk_nlp* dockers up and running (both in the background with the *-d* flag)

    docker-compose up -d stanford_nlp nltk_nlp

Then run the *doc_processor* docker

    docker-compose up doc_processor

This will process 248 **.xhtml* files into **.json* files.

### F.3 Using the *Standford CoreNLP with custom NERs* docker
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

### F.4 Import json data into Neo4j database
Now, open a browser and point at [Neo4j](http://localhost:7474), you will see the interface to access and run some queries with Neo4j. You can also manually type into the address box:

    http://localhost:7474

If it is the first time you access Neo4j from the browser, you will see a form **Connect to Neo4j**, type *neo4j* into the *Username* edit box,
and *path_poc* (all small caps and an underscore character) into the *Password* edit box, then click *Connect* button.

#### F.4.1 Test if Neo4j is ready
Copy and paste the following query into the edit box started with the prompt **neo4j$** to test if the database is ready

    CALL dbms.components()
        YIELD name, versions, edition
    UNWIND versions AS version
    RETURN name, version, edition
    UNION 
    RETURN "APOC" AS name, apoc.version() AS version, "" AS edition
    UNION 
    RETURN "GDS" AS name, gds.version() AS version, "" AS edition;


You can click the **blue arrow** or press *Cmd+Enter* (after copy the query into the **neo4j$** prompt and your mouse course is still inside that box.) Below is what you should see:

| name | version        | edition |             |
|------|----------------|---------|-------------|
| 1    | "Neo4j Kernel" | "4.4.3" | "community" |

#### F.4.2 Import json data into Neo4j
Now, open *Finder*, navigate to the folder *path_poc*, go into sub-folder *cql*, open the file **all_in_one.cql** with *TextEdit.app* (left click, select Open, select *TextEdit.app*).

Use *Cmd+A* to select all the text, *Cmd+C* to copy the content of the text file, then move to the browser, copy the query into the **neo4j$** prompt and run it by *Cmd+Enter*. Wait for a few minutes. When you see all the checkboxes are green-checked, then it is done (anything else can be trouble.)

Inspect the database by looking at its statistics, copy, paste, and run the following:

    CALL apoc.meta.stats() YIELD labelCount, relTypeCount, propertyKeyCount, nodeCount, relCount, labels, relTypes, stats
    RETURN stats;

You should see the result starts with something similar as below,

    "relTypeCount": 4,
    "propertyKeyCount": 30,
    "labelCount": 35,
    "nodeCount": 40886,
    "relCount": 275835,

### G. Data Mining Cases
Starts the *neodash* docker by

    docker-compose up -d neodash

Click on *NEW DASHBOARD* if it is your first time. Then fill the password *path_poc*, and click *CONNECT* to connect to Neo4j.

Now, click on the *Load Dashboard* button on the left side, navigate to the *path_poc* directory, and load the *dashboard.json* file.

Follow the instructions on the dashboard.

After loading, you can click on the *Save Dashboard* to save it to Neo4j.

### H. Refactorings

### H.1 Reprocessing a a few xhtml document
First, for each document, for example *11-HCAA-CA4-01139_Authorization.xhtml* you need to reprocess by running:

    docker-compose run --rm doc_processor 11-HCAA-CA4-01139_Authorization.xhtml

and then clean up Neo4j with queries,

    CALL apoc.periodic.iterate(
    "
        MATCH (n)
        RETURN n
    ","
        DETACH DELETE n;
    ",
    {
        batchSize:1000, iterateList:true, parallel:false
    });

and then import the json data into Neo4j as described above.

### H.2 Define new or modify existing named entities
If you define new or modify existing named entities (in *conf/regexner.mappings*), then you need to rerun the NLP processing:

    docker-compose stop stanford_nlp
    docker-compose up -d stanford_nlp
    docker-compose up -d doc_processor

and then clean up Neo4j with queries,

    CALL apoc.periodic.iterate(
    "
        MATCH (n)
        RETURN n
    ","
        DETACH DELETE n;
    ",
    {
        batchSize:1000, iterateList:true, parallel:false
    });

and then import the json data into Neo4j as described above.

    
    