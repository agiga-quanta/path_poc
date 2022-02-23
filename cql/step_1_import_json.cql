// Note: This script will be processed by neo4j-shell utility
// All comments in Java Style: line preceded by //
// Its syntax must be list of cypher queries and neo4j-shell commands
// separated by ';'
//
// CONSTRAINTS AND INDEXES
//
// 1. Create unique constraint
// CREATE CONSTRAINT ON (n:Label) ASSERT n.property IS UNIQUE;
//
// 2. Create a single-property index
// CREATE INDEX ON :Label(property);
//
// 3. Create a composite index
// CREATE INDEX ON :Label(prop1, …​, propN);
//
// 4. Create node property existence constraint
// CREATE CONSTRAINT ON (n:Label) ASSERT EXISTS(n.property);
//
// 5. Create relationship property existence constraint
// CREATE CONSTRAINT ON ()-[r:relationshipType]-() ASSERT EXISTS(r.property);
//
// 6. Create a Node Key
// ASSERT (variable.propertyName_1, …​, variable.propertyName_n) IS NODE KEY;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// PATH Authorization
//
CREATE CONSTRAINT ON (n:PATH) ASSERT n.uid IS UNIQUE;
CREATE INDEX ON :PATH(date_of_issuance);
CREATE INDEX ON :PATH(project_location);
// - props: ids
// - props: proponent
// - props: project
// - props: description
// - props: conditions
//
CREATE INDEX file_name_content FOR (n:SENTENCE) ON (n.file_name, n.text);
// - props: index, entitymentions, tokens
CREATE INDEX path_sentence FOR ()-[r:HAS_SENTENCE]-() ON (r.section, r.item);
//
CREATE CONSTRAINT ON (n:KEY_PHRASE) ASSERT n.text IS UNIQUE;
//
CREATE INDEX ON :NAMED_ENTITY(text);
//
CREATE CONSTRAINT ON (n:NE_BUILDING) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_ECOLOGY) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_FOOTPRINT) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_SPECIES) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_WATERBODY) ASSERT n.text IS UNIQUE;
//
CREATE CONSTRAINT ON (n:NE_PERSON) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_LOCATION) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_ORGANIZATION) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_MISC) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_MONEY) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_NUMBER) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_ORDINAL) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_PERCENT) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_DATE) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_TIME) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_DURATION) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_SET) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_CAUSE_OF_DEATH) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_CITY) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_COUNTRY) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_CRIMINAL_CHARGE) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_EMAIL) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_HANDLE) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_IDEOLOGY) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_NATIONALITY) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_RELIGION) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_STATE_OR_PROVINCE) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_TITLE) ASSERT n.text IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_URL) ASSERT n.text IS UNIQUE;
//
// Lemmatized word
//
CREATE CONSTRAINT ON (n:WORD) ASSERT n.stem IS UNIQUE;
// - l is the stem form of the text, it is unique and indexed
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
CALL apoc.custom.asFunction(
    'extract_terms',
    'WITH REDUCE(s="", e IN $phrases | s + e + ". ") AS terms
        CALL apoc.load.jsonParams($stanford_url, {method: "POST", contentType: "plain/text"}, terms) 
            YIELD value AS terms_nlp
    WITH terms_nlp 
        CALL apoc.load.jsonParams($nltk_url, {method: "POST", contentType: "application/json"}, apoc.convert.toJson(terms_nlp)) 
            YIELD value AS terms_stem
    RETURN REDUCE(l = [], s IN terms_stem.sentences | l + [[e IN REVERSE(TAIL(REVERSE(s.tokens))) WHERE SIZE(e.stem) > 1 | [e.stem, e.originalText]]]) 
        AS list_of_terms',
    'LIST OF LIST OF STRING',
    [['phrases', 'LIST OF STRING'], ['stanford_url', 'STRING'], ['nltk_url', 'STRING']],
    TRUE,
    'Natural language process a list of terms into list of lemmatized words'
);
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// List all constraints
CALL db.constraints();
//
// List all indexes
CALL db.indexes();
//
// Wait for all indexes online
CALL db.awaitIndexes();
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// List all custom queries
CALL apoc.custom.list();
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Load list of file names for all *.json files in /import directory
// Load each of *.json files in /import directory
//
CALL apoc.periodic.iterate(
"
    CALL apoc.load.directory('*.json')
        YIELD value
    WITH value AS file_name ORDER BY file_name ASC
        CALL apoc.load.json(file_name)
            YIELD value
    RETURN
        SUBSTRING(file_name, 0, apoc.text.indexOf(file_name, '_Auth')) AS file_name,
        value AS json
", "
    WITH file_name, json
        MERGE (doc:PATH {uid: file_name})
            ON CREATE SET 
                doc.date_of_issuance = CASE SIZE(json.headers.date_of_issuance) > 0
                    WHEN TRUE THEN DATE(json.headers.date_of_issuance) ELSE null END,
                doc.authorization_no = CASE SIZE(json.headers.authorization_no) > 0
                    WHEN TRUE THEN json.headers.authorization_no ELSE null END,
                doc.dfo_file_no = CASE SIZE(json.headers.dfo_file_no) > 0
                    WHEN TRUE THEN json.headers.dfo_file_no ELSE null END,
                doc.path_no = CASE SIZE(json.headers.path_no) > 0
                    WHEN TRUE THEN json.headers.path_no ELSE null END,
                doc.path_no = CASE SIZE(json.headers.path_no) > 0
                    WHEN TRUE THEN json.headers.path_no ELSE null END,

                doc.proponent_organization = CASE SIZE(json.proponent.organization) > 0
                    WHEN TRUE THEN json.proponent.organization ELSE null END,
                doc.proponent_place = CASE SIZE(json.proponent.place) > 0
                    WHEN TRUE THEN json.proponent.place ELSE null END,
                doc.proponent_city = CASE SIZE(json.proponent.city) > 0
                    WHEN TRUE THEN json.proponent.city ELSE null END,
                doc.proponent_province = CASE SIZE(json.proponent.state_or_province) > 0
                    WHEN TRUE THEN json.proponent.state_or_province ELSE null END,
                doc.proponent_postcode = CASE SIZE(json.proponent.postcode) > 0
                    WHEN TRUE THEN json.proponent.postcode ELSE null END,
                doc.proponent_person = CASE SIZE(json.proponent.person) > 0
                    WHEN TRUE THEN json.proponent.person ELSE null END,
                doc.proponent_title = CASE SIZE(json.proponent.title) > 0
                    WHEN TRUE THEN json.proponent.title ELSE null END,

                doc.project_nearest_community = CASE SIZE(json.location.nearest_community) > 0
                    WHEN TRUE THEN json.location.nearest_community ELSE null END,
                doc.project_municipality = CASE SIZE(json.location.municipality) > 0
                    WHEN TRUE THEN json.location.municipality ELSE null END,
                doc.project_province = CASE SIZE(json.location.province) > 0
                    WHEN TRUE THEN json.location.province ELSE null END,
                doc.project_watercourse = CASE SIZE(json.location.watercourse) > 0
                    WHEN TRUE THEN json.location.watercourse ELSE null END,
                doc.project_geo_location = CASE SIZE(json.location.geo_location) > 0
                    WHEN TRUE THEN json.location.geo_location ELSE null END,
                doc.project_location = CASE SIZE(json.location.geocode) > 0
                    WHEN TRUE THEN POINT({latitude: json.location.geocode[0], longitude: json.location.geocode[1]}) ELSE null END;
",
{
    batchSize:10, iterateList:true, parallel:false
});
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Load list of file names for all *.json files in /import directory
// Load each of *.json files in /import directory
//
CALL apoc.periodic.iterate(
"
    CALL apoc.load.directory('*.json')
        YIELD value
    WITH value AS file_name ORDER BY file_name ASC
        CALL apoc.load.json(file_name)
            YIELD value
    RETURN
        SUBSTRING(file_name, 0, apoc.text.indexOf(file_name, '_Auth')) AS file_name,
        value AS json
", "
    WITH file_name, json
        MERGE (doc:PATH {uid: file_name})
    WITH file_name, json, doc    
        UNWIND json.description AS item
    WITH file_name, json, doc, item
        UNWIND item.s AS elem
    WITH file_name, json, doc, item, elem
        MERGE (sent:SENTENCE {file_name: file_name, text: elem.c})
            ON CREATE SET
                sent.named_entities = apoc.convert.toJson(elem.named_entities),
                sent.key_phrases = apoc.convert.toJson(elem.key_phrases)

    WITH file_name, json, doc, item, elem, sent
        FOREACH (kp IN elem.key_phrases |
            MERGE (key_phrase:KEY_PHRASE {text: kp.l})
                ON CREATE SET
                    key_phrase.original = kp.o
            FOREACH (w IN kp.w |
                MERGE (word:WORD {stem: TOLOWER(w.stem)})
                    ON CREATE SET
                        word.lemma = w.lemma
                MERGE (key_phrase)-[:HAS_WORD {pos: w.pos, ner: w.ner}]->(word)
            )
            MERGE (sent)-[:HAS_KEY_PHRASE]->(key_phrase)
        )
        MERGE (doc)-[:HAS_SENTENCE {section: 'd', item: item.name, index: elem.index}]->(sent)

    WITH file_name, json, doc, item, elem, sent
        UNWIND elem.named_entities AS ent
    WITH file_name, json, doc, item, elem, sent, ent
        CALL apoc.merge.node(['NE_' + ent.ner, 'NAMED_ENTITY'], {text: ent.text}) YIELD node AS entity
    WITH file_name, json, doc, item, elem, sent, entity
        MERGE (sent)-[:HAS_NAMED_ENTITY]->(entity);
",
{
    batchSize:10, iterateList:true, parallel:false
});
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Load list of file names for all *.json files in /import directory
// Load each of *.json files in /import directory
//
CALL apoc.periodic.iterate(
"
    CALL apoc.load.directory('*.json')
        YIELD value
    WITH value AS file_name ORDER BY file_name ASC
        CALL apoc.load.json(file_name)
            YIELD value
    RETURN
        SUBSTRING(file_name, 0, apoc.text.indexOf(file_name, '_Auth')) AS file_name,
        value AS json
", "
    WITH file_name, json
        MERGE (doc:PATH {uid: file_name})
    WITH file_name, json, doc
        UNWIND json.conditions AS item
    WITH file_name, json, doc, item
        UNWIND item.s AS elem
    WITH file_name, json, doc, item, elem
        MERGE (sent:SENTENCE {file_name: file_name, text: elem.c})
            ON CREATE SET
                sent.named_entities = apoc.convert.toJson(elem.named_entities),
                sent.key_phrases = apoc.convert.toJson(elem.key_phrases)

    WITH file_name, json, doc, item, elem, sent
        FOREACH (kp IN elem.key_phrases |
            MERGE (key_phrase:KEY_PHRASE {text: kp.l})
                ON CREATE SET
                    key_phrase.original = kp.o
            FOREACH (w IN kp.w |
                MERGE (word:WORD {stem: w.stem})
                    ON CREATE SET
                        word.lemma = w.lemma
                MERGE (key_phrase)-[:HAS_WORD {pos: w.pos, ner: w.ner}]->(word)
            )
            MERGE (sent)-[:HAS_KEY_PHRASE]->(key_phrase)
        )   
        MERGE (doc)-[:HAS_SENTENCE {section: 'c', item: item.b, index: elem.index}]->(sent)

    WITH file_name, json, doc, item, elem, sent
        UNWIND elem.named_entities AS ent
    WITH file_name, json, doc, item, elem, sent, ent
        CALL apoc.merge.node(['NE_' + ent.ner, 'NAMED_ENTITY'], {text: ent.text}) YIELD node AS entity
    WITH file_name, json, doc, item, elem, sent, entity
        MERGE (sent)-[:HAS_NAMED_ENTITY]->(entity)
",
{
    batchSize:10, iterateList:true, parallel:false
});
//
////////////////////////////////////////////////////////////////////////
