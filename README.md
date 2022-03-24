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
You will need curl to automatically download binary data from an online repository like [Dropbox](https://www.dropbox.com). However this is not necessary if you already have the project data in a local folder.

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
Note that this process is only necessary if importing zip files into a local folder.

Create a *data* sub-folder,

    mkdir data

Obtain the binary **xhtml.zip**, which contains all content previously *extracted* from pdf files and **manually fixed** and placed it into the *data/* directory.

    cd data
    unzip xhtml.zip
    cd ..

Obtain the binary **jzon.zip**, which contains all *natural language processed* content from *xhtml* files into *json* files and placed it into the *data/* directory.

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

### F.1 Extracting data from pdf files into .xhtml format
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
This step wold be performed if, for instance, a new dataset were being used in the pipeline,  or if we wanted to modify the content of the query cases.  The document processor uses the file *dp.ini* inside the folder *conf* to define the regular expressions that let the NLP tag parts of the document appropriately.  For instance, running a new case looking at a different part of the document would require a configuration component telling the processor how to identify and tag that part of the document,  then how to clean it if necessary. 
    
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
This section uses NLP parts-of-speech analysis to identify key entities in the sections of the document we are interested in.
    
*Note:* you can check which dockers are running by:

    docker-compose ps

If *stanford_nlp* and *nltk_nlp* are already running, then start the *neo4j* docker:

    docker-compose up -d neo4j

If none of them are running, then run:

    docker-compose up -d stanford_nlp nltk_nlp neo4j

Now, open a browser and point at [Stanford CoreNLP with custom NERs](http://localhost:9000), you will see the interface to access and run some queries with the Stanford CoreNLP with custom named-entities are defined. You can also manually type into the address box:

    http://localhost:9000

In the **- Annotations -** dropbox, select *part-of-speech*, *lemmas*, *named entities*, *named entities (regexner)*, *constituency parse* in **this order**, copy and paste the following paragraph into the **- Text to annotate -** box.

    Scale and description of offsetting measures: Offsetting shall be carried out in accordance with the description below and as set out in the Proponent's Offsetting Plan and shall be undertaken at the Millhaven terminal site, the Stella terminal site, and Clark Island in Hay Bay, Lake Ontario.

It would take sometime to load the machined-learned (ML) datasets for the first run (or anytime when you change the set of annotators). 

You now can see how the words are isolated, lemmatized, part-of-speech captured, named entities are recognized,

![CoreNLP output](/img/corenlp-output.png)

and the tree of the constituency parsing result

![Constituency tree](/img/nlp-tree.png)

### F.4 Import json data into Neo4j database
Neo4j is used to construct a graph database in whcih we can run queries about the documents we have processed so far. 
    
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

Note that the [Neo4j APOC Library](https://neo4j.com/developer/neo4j-apoc/), or *Awesome Procedures On Cypher (APOC)* is a set of amazing Cypher functions and procedures that greatly help to use Neo4j within its vast ecosystem of software.

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

### F.5 Inspecting the metagraph

    CALL apoc.meta.graph

![Meta graph](/img/meta_graph.png)

### G. Data Mining Cases
Starts the *neodash* docker by

    docker-compose up -d neodash

Click on *NEW DASHBOARD* if it is your first time. Then fill the password *path_poc*, and click *CONNECT* to connect to Neo4j. Now, click on the *Load Dashboard* button on the left side, navigate to the *path_poc* directory, and load the *dashboard.json* file.

#### G.1 Load Dashboard

![Load Dashboard](/img/load_dashboard.png)

Follow the instructions on the dashboard.
After loading, you can click on the *Save Dashboard* to save it to Neo4j.

#### G.2 Status & Statistics

The dashboard contains a number of tabs. The first one is *Status & Statistics.* On this tab the version of *Neo4j* and the libraries *APOC*, *GDS* are shown in the left panel. The middle and right panels show the node and relationship statistics.

![Status & Statistics](/img/status_stat.png)

#### G.2.1 Custom configuraton and Cypher for Status & Statistics

Note that each panel can be customized by clicking on the three vertical dots (settings icon) at the top-right corner of the panel. The panel can be zoomed to full-screen by clicking on the square icon next to the settings icon. The size of the panel can easily be selected from a dropdown box. The type of the panel depends on the **type of the returned data** by the Cypher query.

![Load Dashboard](/img/status_stat_2.png)

The content of the panel is the Cypher query that runs and obtains information from the database, which is exactly the same Cypher we used earlier to inspect the database.

    CALL dbms.components()
        YIELD name, versions, edition
    UNWIND versions AS version
    RETURN name, version, edition
    UNION 
    RETURN "APOC" AS name, apoc.version() AS version, "" AS edition
    UNION 
    RETURN "GDS" AS name, gds.version() AS version, "" AS edition;

***Thus, by adding a custom panel, configure a Cypher query and its return type, you can dynamically and gradually build up a powerful data mining application.***

#### G.2.2 Tab for Case 1 - Input

![Case 1 - Input](/img/case_1_input.png)

##### G.2.2.1 Description Panel
The first data mining case (Case 1) is described in [Markdown](https://www.markdownguide.org/getting-started/) language as below. Note that this is a static text and has zero effect on the input or output of the data mining.

Looking a:
- section **Description**,
- paragraph **serious harm to fish**, started with the sentence specified by the regular expression: *The\s+serious\s+harm\s+to\s+fish\s+(and\s+impacts\s+to\s+aquatic\s+species\s+at\s+risk\s+)?likely\s+to\s+result\s+from\s+the\s+proposed\s+work(s|\(s\))?\,\s+undertaking(s|\(s\))?\,\s?or\s+activit(ies|y(\(ies\))?)?\,\s?and\s+covered\s+by\s+this\s+authorization\s+(includes|are)(\;|\:)?*,
- detects if there is any **foot prints** such as *12 m2*,
- extract terms matched **impacts**, such as *death of fish, destruction, disruption, harmful alteration, kill, loss, permanent alteration, permanent destruction, temporary alteration*
- or matches **reasons**, such as *abutment, armouring, bank protection, berms, causeway, changes to flow, channel deepening, channel realignment, coffer dam, cofferdam, concrete pipe, construction, culvert, dewatering, dredging, entrainment, extension, fill, hydraulic impact, impingement, in-stream pier, incidental, infilling, instream pier, pier, piles, placement of sand, re-sloping, realignment, rip rap, riprap, rock fill, shoreline protection, spur, temporary infilling*

![Case 1 - Impact and Reason terms](/img/case_1_description_markdown.png)

##### G.2.2.2 Input: Impact and Reasons Terms

Below the description panels are two panels. The first panel for *accepting, analyzing , and storing* custom terms for impact and reason (as described in the description panel). This is, again, a customizable panel with a predefined query, where the terms in the two list of terms can be easily modified.

![Case 1 - Impact and Reason terms](/img/case_1_terms_query.png)

    WITH
        [
            "death of fish",
            "destroy",
            "destruction",
            "disruption", 
            "harmful alteration", 
            "kill",
            "loss",
            "permanent alteration", 
            "permanent destruction",
            "temporary alteration"
        ] AS impacts,
        [
            "abutment",
            "armouring",
            "bank protection",
            "bank stabilization",
            "berms",
            "causeway",
            "changes to flow",
            "channel deepening",
            "channel realignment",
            "coffer dam",
            "cofferdam",
            "concrete pipe",
            "construction",
            "culvert",
            "dewatering",
            "dredging",
            "entrainment",
            "extension",
            "fill",
            "hydraulic impact",
            "impingement",
            "in-stream pier",
            "incidental",
            "infilling",
            "instream pier",
            "pier",
            "piles", 
            "placement of sand",
            "re-sloping",
            "realignment",
            "rip rap",
            "riprap",
            "rock fill",
            "shoreline protection",
            "spur",
            "temporary infilling"
        ] AS reasons,
        "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"  AS stanford_url,
        "http://nltk_nlp:6543/stem"  AS nltk_url
    MERGE (n:DM1)
        SET 
            n.impacts = apoc.convert.toJson(custom.run_nlp(impacts, stanford_url, nltk_url)),
            n.reasons = apoc.convert.toJson(custom.run_nlp(reasons, stanford_url, nltk_url))
    RETURN
        SIZE(apoc.convert.fromJsonList(n.impacts)) AS dm1_impacts,
        SIZE(apoc.convert.fromJsonList(n.reasons)) AS dm1_reasons;

Note that the output is stored in a single node with the label *DM1* (data mining 1.) 

##### G.2.2.3 Input: List of PATH cases to be investigated.

The list of PATH cases to be investigated, each identification is the prefix of the file name without the *_Authorization* and extention (such as *.pdf*).

![Case 1 - List of PATH cases](/img/case_1_path_query.png)

    WITH
        [
            '14-HCAA-00225',
            '14-HCAA-01139',
            '14-HCAA-00258',
            '17-HCAA-01168'
        ] AS path_uid_list
    MERGE (n:DM1)
        SET n.path_uid_list = path_uid_list
    RETURN SIZE(path_uid_list) AS number_of_paths;

Note that the output is also stored in the node with label *DM1* (data mining 1.) 

Note that if you want to run the query of the case for **all** document, you must leave the list of the documents **empty** as shown below

    ...
    WITH
        [
        ] AS path_uid_list
    ...

##### G.2.2.4 Output

The output query is shown in the image below.

![Case 1 - Output query](/img/case_1_output_query.png)

Lets dissect it. First the query access the input information stored in the *DM1* node, use them to fetch the *PATH* nodes, representing the PATH documents (with identifications defined in the list of PATH cases, as explained above), where the item ***impact_harm*** of the section ***d*** contains a *named entity* with type ***NE_FOOTPRINT***.

For example *14-HCAA-00225* contains *To account for variability in impingement and entrainment values, Bruce Power is authorized to kill up to a maximum loss of loss of 6600 kilogram per year (kg/yr) calculated by HPI.*

Here is the partial (and runable) query

    MATCH (n:DM1)
    WITH 
        apoc.convert.fromJsonList(n.impacts) AS dm1_impacts,
        apoc.convert.fromJsonList(n.reasons) AS dm1_reasons,
        n.path_uid_list AS path_uid_list
        MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'd'}]-(sentence:SENTENCE)-[:HAS_NAMED_ENTITY]->(foot_print:NE_FOOTPRINT)
            WHERE CASE SIZE(path_uid_list) > 0 WHEN TRUE THEN doc.uid IN path_uid_list ELSE TRUE END AND 
                r.item = 'impact_harm'
    RETURN doc, sentence, foot_print;

![Case 1 - Partial output query](/img/case_1_doc_sent_fp.png)

Then it continues to collect all *KEY_PHRASE* nodes of the sentences,

    MATCH
        (sentence)-[:HAS_KEY_PHRASE]->(impact_phrase:KEY_PHRASE)-[:HAS_WORD]->(iword:WORD),
        (sentence)-[:HAS_KEY_PHRASE]->(reason_phrase:KEY_PHRASE)-[:HAS_WORD]->(rword:WORD)
    WHERE impact_phrase <> reason_phrase

and makes sure that ***at least one impact term*** and ***at least one reason term*** are among those,

    WHERE
        ANY(term IN dm1_impacts WHERE apoc.coll.containsAll(iwords, [e IN term | e[0]])) AND
        ANY(term IN dm1_reasons WHERE apoc.coll.containsAll(rwords, [e IN term | e[0]]))

then return whatever other meaningful named entities among *LOCATION, ORGANIZATION, PERSON, TITLE,BUILDING, ECOLOGY,* or *WATERBODY.*

    WITH
        [
            'NE_LOCATION', 
            'NE_ORGANIZATION', 
            'NE_PERSON', 
            'NE_TITLE',
            'NE_BUILDING',
            'NE_ECOLOGY',
            'NE_WATERBODY'
        ] AS entity_types,
        ...
        OPTIONAL MATCH (sentence)-[:HAS_NAMED_ENTITY]->(entity)
            WHERE SIZE(apoc.coll.intersection(entity_types, LABELS(entity))) > 0

![Case 1 - Output](/img/case_1_output.png)

Below is the textual output.

| path_uid      | foot_prints                                                               | impact_phrases                            | reason_phrases                                                           | named_entities              | sentence                                                                                                                                                                                                                                                                                                                                                                                            |   |
|---------------|---------------------------------------------------------------------------|-------------------------------------------|--------------------------------------------------------------------------|-----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---|
| 14-HCAA-00225 | [6600 kilogram per year]                                                  | [[[kill],[loss]]]                         | [[[entrainment],[impingement]]]                                          | [[Bruce Power,HPI]]         | To account for variability in impingement and entrainment values, Bruce Power is authorized to kill up to a maximum loss of loss of 6600 kilogram per year (kg/yr) calculated by HPI.                                                                                                                                                                                                               |   |
| 14-HCAA-00258 | [2000 square metres of fish habitat]                                      | [[[destruction]]]                         | [[[infilling]]]                                                          | [[]]                        | Destruction of approximately 2000 square metres of fish habitat associated with infilling.                                                                                                                                                                                                                                                                                                          |   |
| 14-HCAA-01139 | [3410 m2 of habitat]                                                      | [[[destruction],[permanent,destruction]]] | [[[infilling]]]                                                          | [[Millhaven terminal site]] | Destruction of approximately 3410 m2 of habitat at the Millhaven terminal site through permanent infilling.                                                                                                                                                                                                                                                                                         |   |
| 14-HCAA-01139 | [2695 m2 of habitat]                                                      | [[[destruction],[permanent,destruction]]] | [[[infilling]]]                                                          | [[Stella terminal site]]    | Destruction of approximately 2695 m2 of habitat at the Stella terminal site through permanent infilling.                                                                                                                                                                                                                                                                                            |   |
| 14-HCAA-01139 | [1930 m2]                                                                 | [[[permanent,alteration]]]                | [[[dredging]]]                                                           | [[Millhaven terminal site]] | Permanent alteration of approximately 1930 m2 at the Millhaven terminal site through dredging.                                                                                                                                                                                                                                                                                                      |   |
| 14-HCAA-01139 | [890 m2]                                                                  | [[[permanent,alteration]]]                | [[[dredging]]]                                                           | [[Stella terminal site]]    | Permanent alteration of approximately 890 m2 at the Stella terminal site through dredging.                                                                                                                                                                                                                                                                                                          |   |
| 14-HCAA-01139 | [575 m2]                                                                  | [[[permanent,alteration]]]                | [[[shoreline,protection]]]                                               | [[Millhaven terminal site]] | Permanent alteration of approximately 575 m2 al the Millhaven terminal site through the installation of shoreline protection.                                                                                                                                                                                                                                                                       |   |
| 14-HCAA-01139 | [497 m2]                                                                  | [[[permanent,alteration]]]                | [[[shoreline,protection]]]                                               | [[Stella terminal site]]    | Permanent alteration of approximately 497 m2 at the Stella terminal site through the installation of shoreline protection.                                                                                                                                                                                                                                                                          |   |
| 17-HCAA-01168 | [17,170 m2 of fish habitat]                                               | [[[permanent,alteration]]]                | [[[coffer,dam],[construction]]]                                          | [[river]]                   | The permanent alteration of 17,170 m2 of fish habitat associated with the construction of coffer dams in the river during the project.                                                                                                                                                                                                                                                              |   |
| 17-HCAA-01168 | [129 m2,6,096 m2,2,672 m2,8,897 m2 of fish habitat,43 m2,394 m2,5,702 m2] | [[[destruction]]]                         | [[[abutment],[berms],[construction],[infilling],[instream,pier],[pier]]] | [[river]]                   | The destruction of 8,897 m2 of fish habitat including: 6,096 m2 associated with infilling along the west (5,702 m2) and east (394 m2) shorelines of the river to construct the two abutments; 2,672 m2 associated with the construction of a toe berm along the front of the left (west) bank abutment; and, 129 m2 associated with the construction of three instream concrete piers (43 m2 each). |   |

#### G.2.3 [Case 5](#case-5)

##### G.2.3.1 Analysis

For case 5, we look for the bullets inside PATH document starting with *Conditions that relate to monitoring and reporting of implementation of offsetting measures* (or similar). First we need to *scan* to see how this text can vary document to document. By assumming that most of these bullets are at **'5'**

    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'c'}]-(s:SENTENCE)
        WHERE r.item IN ['5.']
    RETURN DISTINCT(s.text), COUNT(*);

The result shows as below,

| (s.text)                                                                                                                                                                                              | COUNT(*) |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| Conditions that relate to monitoring and reporting of offsetting measures (described above in section 4):                                                                                             | 38       |
| Conditions that relate to monitoring and reporting of compensation (described above):                                                                                                                 | 7        |
| Conditions that relate to monitoring and reporting of habitat offsets (described above):                                                                                                              | 2        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4):                                                                           | 154      |
| Conditions that relate to monitoring and reporting of offsetting measures (described  above in section 4):                                                                                            | 2        |
| Conditions that relate to monitoring and reporting of measures and standards to avoid and mitigate serious harm to fish from project related shipping:                                                | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures  (described in section 4):                                                                                | 2        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above under condition 4):                                                                      | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in condition 4):                                                                         | 5        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in Section 4)                                                                            | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4)                                                                            | 3        |
| Conditions that relate to monitoring and reporting or implementation of offsetting measures (described above in section 4):                                                                           | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4);                                                                           | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described in section 4):                                                                                 | 11       |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures(described above in section 4):                                                                            | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (as described in Condition 4 above)                                                                       | 5        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4): N/A                                                                       | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in Condition 4):                                                                         | 1        |
| Conditions that relate to the offsetting of the serious harm to fish likely to result from the authorized work, undertaking or activity                                                               | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4):Not applicable at this time (see Condition 4.2 above)                      | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4): Not applicable at this time (see Condition 4.2 above)                     | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4): Not applicable at this time.                                              | 2        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4):Not applicable at this time.                                               | 1        |
| Details shall be provided as per 4.2.                                                                                                                                                                 | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures:                                                                                                          | 1        |
| Conditions that relate to monitoring and reporting of works to be included in the habitat banking agreement between the City of Kitchener and DFO:                                                    | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures  (described above in section 4): Not applicable at this time due to the emergency nature of the  project. | 1        |
| An offsetting monitoring plan shall be provided with the offsetting proposal as per 4.2.                                                                                                              | 1        |
| Details shall be provided as per 4.2,                                                                                                                                                                 | 1        |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures  (described above in section 4):                                                                          | 2        |

Then we combine possible bullet texts into a single regular expression,

    'Conditions\\s+that\\s+relate\\s+to\\s+monitoring\\s+and\\s+reporting\\s+of(\\s+implementation\\s+of)?\\s+(offsetting\\s+measures|compensation|habitat\\s+offsets).*'

and forming a test query to see how many documents contains this text at a *first level* bullet (e.g. *4., 5., 6., 7., ...*)

    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'c'}]-(s:SENTENCE)
        WHERE SIZE(r.item) = 2 AND
            s.text =~ 'Conditions\\s+that\\s+relate\\s+to\\s+monitoring\\s+and\\s+reporting\\s+of(\\s+implementation\\s+of)?\\s+(offsetting\\s+measures|compensation|habitat\\s+offsets).*'
    RETURN DISTINCT(s.text), COUNT(*) AS count, COLLECT(DISTINCT(r.item)) AS bullets;

The result shows **246** such documents (the *count* column shows the number of documents with the same text, the *bullets* columns show the bullets containing such text).

| (s.text)                                                                                                                                                                                              | count | bullets |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------|---------|
| Conditions that relate to monitoring and reporting of offsetting measures (described above in section 4):                                                                                             | 38    | [5.]    |
| Conditions that relate to monitoring and reporting of compensation (described above):                                                                                                                 | 7     | [5.]    |
| Conditions that relate to monitoring and reporting of habitat offsets (described above):                                                                                                              | 2     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4):                                                                           | 154   | [5.]    |
| Conditions that relate to monitoring and reporting of offsetting measures (described  above in section 4):                                                                                            | 2     | [5.]    |
| Conditions that relate to monitoring and reporting of offsetting measures (described above in section 6:                                                                                              | 1     | [7.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures  (described in section 4):                                                                                | 2     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above under condition 4):                                                                      | 1     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in condition 4):                                                                         | 5     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in Section 4)                                                                            | 1     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4)                                                                            | 3     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4);                                                                           | 1     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described in section 4):                                                                                 | 11    | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures(described above in section 4):                                                                            | 1     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (as described in Condition 4 above)                                                                       | 5     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4): N/A                                                                       | 1     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in Condition 4):                                                                         | 1     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 5):                                                                           | 1     | [7.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4):Not applicable at this time (see Condition 4.2 above)                      | 1     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4): Not applicable at this time (see Condition 4.2 above)                     | 1     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4): Not applicable at this time.                                              | 2     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures (described above in section 4):Not applicable at this time.                                               | 1     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures:                                                                                                          | 1     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures  (described above in section 4): Not applicable at this time due to the emergency nature of the  project. | 1     | [5.]    |
| Conditions that relate to monitoring and reporting of implementation of offsetting measures  (described above in section 4):                                                                          | 2     | [5.]    |

##### G.2.3.2 Input terms and list of authorizations

Now, we need to prapare the list of terms, process them, and store them into a new **DM5** node

    WITH
        [
            "photographic record",
            "visual inspection",
            "underwater imagery",
            "fish species assessment",
            "stable isotope analysis",
            "written report",
            "riparian revegetation assessment",
            "assessment result",
            "distribution assessment",
            "habitat assessment",
            "assessment study",
            "riparian disturbance assessment",
            "offsetting measure",
            "post-construction monitoring",
            "postconstruction monitoring",
            "monitoring"
        ] AS key_phrases,
        "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"  AS stanford_url,
        "http://nltk_nlp:6543/stem"  AS nltk_url
    MERGE (n:DM5)
        SET 
            n.key_phrases = apoc.convert.toJson(custom.run_nlp(key_phrases, stanford_url, nltk_url))
    RETURN
        SIZE(apoc.convert.fromJsonList(n.key_phrases)) AS key_phrases;

as well a the list of authorizations,

    WITH
        [
            '16-HCAA-01734',
            '17-HCAA-00829',
            '18-HCAA-00253'
        ] AS path_uid_list
    MERGE (n:DM5)
        SET n.path_uid_list = path_uid_list
    RETURN SIZE(path_uid_list) AS path_uid_list;

##### G.2.3.3 The query

Finally the query itself

    MATCH (n:DM5)
    WITH
        apoc.convert.fromJsonList(n.key_phrases) AS dm5_key_phrases,
        n.path_uid_list AS path_uid_list
        MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'c'}]-(s:SENTENCE)
        WHERE CASE SIZE(path_uid_list) > 0 WHEN TRUE THEN doc.uid IN path_uid_list ELSE TRUE END AND 
            SIZE(r.item) = 2 AND
            s.text =~ 'Conditions\\s+that\\s+relate\\s+to\\s+monitoring\\s+and\\s+reporting\\s+of(\\s+implementation\\s+of)?\\s+(offsetting\\s+measures|compensation|habitat\\s+offsets).*'
    WITH dm5_key_phrases, doc, r.item AS ri
        MATCH (doc)-[r:HAS_SENTENCE {section: 'c'}]-(sentence:SENTENCE)
            WHERE r.item STARTS WITH ri AND r.item <> ri
    WITH dm5_key_phrases, doc, sentence ORDER BY doc.uid ASC, r.i ASC
        MATCH (sentence)-[:HAS_NAMED_ENTITY]->(entity:NE_DATE)
    WITH dm5_key_phrases, doc, sentence, COLLECT(DISTINCT(entity.text)) AS dates
        OPTIONAL MATCH (sentence)-[:HAS_KEY_PHRASE]->(key_phrase:KEY_PHRASE)-[:HAS_WORD]->(word:WORD)
    WITH dm5_key_phrases, doc, sentence, dates, COLLECT(DISTINCT(word.stem)) AS words
    WITH dm5_key_phrases, doc, sentence, dates, COLLECT(words) AS key_phrases
    WITH dm5_key_phrases, doc, sentence, dates,
        REDUCE(r = [], term IN dm5_key_phrases | 
            CASE ANY(phrase IN key_phrases WHERE apoc.coll.containsAll(phrase, [e IN term | e[0]]))
                WHEN TRUE THEN r + [[e IN term | e[1]]] ELSE r END
        ) AS key_phrases
    RETURN doc.uid, dates, key_phrases, sentence.text;

##### G.2.3.4 The result

| doc.uid       | dates                                                                     | key_phrases                                                                                                                                      | sentence.text                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
|---------------|---------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 16-HCAA-01734 | [once,December 31 2019]                                                   | [[stable,isotope,analysis]]                                                                                                                      | The stable isotope analysis study shall be deemed successful once the postconstruction data are collected and final report/results are submitted to DFO by December 31 2019.                                                                                                                                                                                                                                                                                                              |
| 16-HCAA-01734 | [2018,spring,summer]                                                      | [[fish,species,assessment],[offsetting,measure]]                                                                                                 | Fish species assessments will be undertaken by a qualified biologist and completed for the in- water offset measures, using multiple non-lethal gear types in a standardized and repeatable manner, over 5 years in year 1, 3 and 5 starting in 2018 in the spring and summer; and,                                                                                                                                                                                                       |
| 16-HCAA-01734 | [2018]                                                                    | [[photographic,record]]                                                                                                                          | A digital photographic record of preconstruction, during construction and postconstruction conditions shall be compiled using the same vantage points and direction to show that the approved works have been completed in accordance with the Offsetting Plan over 5 years in year 1, 3 and 5 starting in 2018;                                                                                                                                                                          |
| 16-HCAA-01734 | [December 21, 2016]                                                       | [[offsetting,measure],[monitoring]]                                                                                                              | Schedule(s) and criteria:The Proponent shall conduct monitoring of the implementation of offsetting measures according to the approved timeline and criteria below and as set out within the approved Offsetting Plan contained within the Goderich Harbour Wharf Expansion Fisheries ACT Application dated December 21, 2016 and supporting information, or any subsequent version, approved by DFO:                                                                                     |
| 16-HCAA-01734 | [2018]                                                                    | [[visual,inspection],[underwater,imagery]]                                                                                                       | The function and stability of submerged physical structures shall be assessed by visual inspection and underwater imagery over 5 years in year 1, 3 and 5 starting in 2018;                                                                                                                                                                                                                                                                                                               |
| 16-HCAA-01734 | [December 31, 2019,December 31, 2018,December 31, 2022,December 31, 2020] | [[underwater,imagery],[stable,isotope,analysis],[written,report]]                                                                                | Written reports (as described above under conditions 5.1.1.1 to 5.1.1.4) including photographs, underwater imagery and georeferenced maps shall be submitted in an annual report to DFO on or before December 31, 2018 (Year 1, Swan Lake wetland and habitat pod projects); December 31, 2019 (stable isotope analysis study only), December 31, 2020 (Year 3, Swan Lake wetland and habitat pod projects); and, December 31, 2022 (Year 5, Swan Lake wetland and habitat pod projects). |
| 17-HCAA-00829 | [once]                                                                    | []                                                                                                                                               | This component of the offsetting plan only needs to be undertaken once.                                                                                                                                                                                                                                                                                                                                                                                                                   |
| 17-HCAA-00829 | [December 31, 2018,2020,2019]                                             | [[riparian,revegetation,assessment],[assessment,result],[monitoring]]                                                                            | The riparian revegetation assessment results shall be provided in the Years 1, 2 and 3 Post- Construction Monitoring Reports which are due on or before December 31, 2018, 2019 and 2020, respectively.                                                                                                                                                                                                                                                                                   |
| 17-HCAA-00829 | [August 31, 2018]                                                         | [[distribution,assessment],[habitat,assessment],[assessment,study],[riparian,disturbance,assessment]]                                            | The Mapleleaf distribution/habitat assessment study and riparian disturbance assessment shall be completed before August 31, 2018.                                                                                                                                                                                                                                                                                                                                                        |
| 17-HCAA-00829 | [December 31, 2018,the Year]                                              | [[distribution,assessment],[habitat,assessment],[assessment,study],[riparian,disturbance,assessment],[postconstruction,monitoring],[monitoring]] | The Mapleleaf distribution/habitat assessment study and riparian disturbance assessment shall be provided to DFO, including a copy to the Senior Species at Risk Biologist identified above, as a separate report or as part of the Year 1 PostConstruction Monitoring Report which is due by no later than December 31, 2018.                                                                                                                                                            |
| 18-HCAA-00253 | [January 15 *, 2023]                                                      | [[offsetting,measure]]                                                                                                                           | The Proponent shall report to DFO on whether the offsetting measures were conducted according to the conditions of this authorization by providing a report to be submitted no later than January 15*, 2023 .                                                                                                                                                                                                                                                                             |
| 18-HCAA-00253 | [2023,December,December 31st, 2025,December 31st, 2024]                   | [[postconstruction,monitoring],[monitoring]]                                                                                                     | The Proponent shall engage in postconstruction monitoring of the offset works for a period of three years following the completion of offsetting works with reports submitted to DFO by December 31s1, 2023, December 31st, 2024, and December 31st, 2025.                                                                                                                                                                                                                                |

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

Details instruction is here [Stanford RegexNER](https://nlp.stanford.edu/software/regexner.html).

Here are some example mappings,

| Regular expression                                                                                                   | Type         | POS tags            | Confidence |
|----------------------------------------------------------------------------------------------------------------------|--------------|---------------------|------------|
| Truax Dam                                                                                                            | DAM          | ORGANIZATION        | 1.0        |
| Beatty Saugeen River                                                                                                 | WATERBODY    | LOCATION\|TITLE     | 1.0        |
| (Abitibi\|Elbow\|Kananaskis\|Saugeen) River                                                                          | WATERBODY    | LOCATION\|TITLE     | 1.0        |
| Evan Thomas Creek                                                                                                    | WATERBODY    | LOCATION            | 1.0        |
| (Meux\|Otter\|Karel) Creek                                                                                           | WATERBODY    | LOCATION            | 1.0        |
| Lake (Huron\|Ontario) watershed                                                                                      | ECOLOGY      | NNP\|NN             | 1.0        |
| Lake (Huron\|Ontario)                                                                                                | WATERBODY    | LOCATION\|CITY      | 1.0        |
| Otter Rapids                                                                                                         | WATERBODY    | NNP                 | 1.0        |
| walleye                                                                                                              | SPECIES      | NN                  | 1.0        |
| lake sturgeon                                                                                                        | SPECIES      | NN                  | 1.0        |
| sturgeon                                                                                                             | SPECIES      | NN                  | 1.0        |
| white sucker                                                                                                         | SPECIES      | NN                  | 1.0        |
| lake whitefish                                                                                                       | SPECIES      | NN                  | 1.0        |
| Habitat Productivity Index                                                                                           | ECOLOGY      | NNP                 | 1.0        |
| HPI                                                                                                                  | ECOLOGY      | NNP                 | 1.0        |
| HADD                                                                                                                 | ECOLOGY      | NNP                 | 1.0        |
| Flood Damage Repairs                                                                                                 | ECOLOGY      | NNP                 | 1.0        |
| (D\|d)eath of fish                                                                                                   | ECOLOGY      | NN\|IN              | 1.0        |
| Clark Island                                                                                                         | LOCATION     | CITY\|LOCATION      | 1.0        |
| Hay Bay                                                                                                              | LOCATION     | CITY\|LOCATION      | 1.0        |
| Abitibi Canyon                                                                                                       | LOCATION     | NNP\|ORGANIZATION   | 1.0        |
| 25th Avenue Bridge                                                                                                   | BUILDING     | ORDINAL             | 1.0        |
| 25 Avenue SW Bridge                                                                                                  | BUILDING     | CD\|ORDINAL         | 1.0        |
| [A-Z][a-z]+ and [A-Z][a-z]+ terminals                                                                                | BUILDING     | NNP\|CC\|NNS        | 1.0        |
| [A-Z][a-z]+ terminal site                                                                                            | LOCATION     | NNP\|NN             | 1.0        |
| [A-Z][a-z]+ terminal                                                                                                 | BUILDING     | NNP\|NN             | 1.0        |
| [A-Z][a-z]+ pier                                                                                                     | BUILDING     | NNP\|NN             | 1.0        |
| Kananaskis golf course                                                                                               | BUILDING     | NNP\|NN             | 1.0        |
| Station \d \+\d{3}                                                                                                   | BUILDING     | NN\|NNP\|CD         | 1.0        |
| Bruce Power                                                                                                          | ORGANIZATION | PERSON              | 1.0        |
| Matrix Solutions Inc\.                                                                                               | ORGANIZATION | NNP\|NNPS           | 1.0        |
| Fisheries and Oceans Canada \(DFO\)                                                                                  | ORGANIZATION | NNP\|NNPS           | 1.0        |
| Fisheries and Oceans Canada                                                                                          | ORGANIZATION | NNP\|NNPS           | 1.0        |
| Department of Fisheries and Oceans \(DFO\)                                                                           | ORGANIZATION | NNP\|NNPS           | 1.0        |
| Department of Fisheries and Oceans                                                                                   | ORGANIZATION | NNP\|NNPS           | 1.0        |
| ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? to ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? m(eter\|etre)?s?          | FOOTPRINT    | CD\|IN\|NN\|NNS     | 1.0        |
| ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? and ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? c(enti)?m(eter\|etre)?s? | FOOTPRINT    | CD\|IN\|NN\|NNS     | 1.0        |
| minimum of ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? (cubic\|linear\|square) m(eter\|etre)?s? in size              | FOOTPRINT    | CD\|IN\|JJ\|NN\|NNS | 1.0        |
| minimum ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? (cubic\|linear\|square) m(eter\|etre)?s? in size                 | FOOTPRINT    | CD\|JJ\|NN\|NNS     | 1.0        |
| minimum of ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? m2                                                            | FOOTPRINT    | CD\|IN\|JJ\|NN      | 1.0        |
| minimum ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? m2                                                               | FOOTPRINT    | CD\|JJ\|NN          | 1.0        |
| minimum of ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? (hectare)s? in size                                           | FOOTPRINT    | CD\|IN\|JJ\|NN\|NNS | 1.0        |
| minimum ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? (hectare)s? in size                                              | FOOTPRINT    | CD\|JJ\|NN\|NNS     | 1.0        |
| roughly ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? m(eter\|etre)?s? in depth                                        | FOOTPRINT    | RB\|CD\|IN\|NN\|NNS | 1.0        |
| up to ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? m(eter\|etre)?s? in size                                           | FOOTPRINT    | RB\|CD\|IN\|NN\|NNS | 1.0        |
| approximately ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? (kilogram\|kg)s? per [a-z]+                                | FOOTPRINT    | RB\|CD\|IN\|NN\|NNS | 1.0        |
| ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? (cubic\|linear\|square) m(eter\|etre)?s? of fish habitat                 | FOOTPRINT    | CD\|JJ\|NN\|NNS     | 1.0        |
| ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? (cubic\|linear\|square) m(eter\|etre)?s? of habitat                      | FOOTPRINT    | CD\|JJ\|NN\|NNS     | 1.0        |
| ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? (cubic\|linear\|square) m(eter\|etre)?s?                                 | FOOTPRINT    | CD\|JJ\|NN\|NNS     | 1.0        |
| ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? (kilogram\|kg)s? per [a-z]+                                              | FOOTPRINT    | CD\|IN\|NN\|NNS     | 1.0        |
| ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? habitat unit                                                             | FOOTPRINT    | CD\|JJ\|NN\|NNS     | 1.0        |
| ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? m(eter\|etre)?s?                                                         | FOOTPRINT    | CD\|JJ\|NN\|NNS     | 1.0        |
| ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? m2 of fish habitat                                                       | FOOTPRINT    | CD\|IN\|NN\|NNS     | 1.0        |
| ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? m2 of habitat                                                            | FOOTPRINT    | CD\|IN\|NN\|NNS     | 1.0        |
| ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? m2                                                                       | FOOTPRINT    | CD\|NN\|NNS         | 1.0        |
| ((\d{1,3}(\,\d{3})+\|\d{1,3})\|\d+)(\.\d+)? ha                                                                       | FOOTPRINT    | CD\|JJ\|NN\|NNS     | 1.0        |
