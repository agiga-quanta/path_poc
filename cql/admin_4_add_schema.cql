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
CREATE INDEX rel_index_name FOR ()-[r:HAS_SENTENCE]-() ON (r.section, r.item);
//
CREATE CONSTRAINT ON (n:KEY_PHRASE) ASSERT n.text IS UNIQUE;
//
CREATE CONSTRAINT ON (n:FOOT_PRINT) ASSERT n.text IS UNIQUE;
//
CREATE INDEX ON :NAMED_ENTITY(text);
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
CREATE CONSTRAINT ON (n:WORD) ASSERT n.lemma IS UNIQUE;
// - l is the lemma form of the text, it is unique and indexed
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
CALL apoc.custom.asFunction(
    'extract_terms',
    'WITH REDUCE(s="", e IN $phrases | s + e + " .") AS payload
        CALL apoc.load.jsonParams($stanford_url, {method: "POST", contentType: "plain/text"}, payload) 
            YIELD value
    RETURN REDUCE(l = [], s IN value.sentences | l + [[e IN REVERSE(TAIL(REVERSE(s.tokens))) WHERE SIZE(e.lemma) > 2 | e.lemma]]) 
        AS list_of_terms',
    'LIST OF LIST OF STRING',
    [['phrases', 'LIST OF STRING'], ['stanford_url', 'STRING']],
    TRUE,
    'Natural language process a list of terms into list of lemmatized words'
);
//
////////////////////////////////////////////////////////////////////////
