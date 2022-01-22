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
CREATE CONSTRAINT ON (n:PHARSE) ASSERT n.t IS UNIQUE;
//
CREATE CONSTRAINT ON (n:FOOT_PRINT) ASSERT n.t IS UNIQUE;
//

////////////////////////////////////////////////////////////////////////
//
CREATE CONSTRAINT ON (n:SENT) ASSERT n.uid IS UNIQUE;
// - props: index, entitymentions, tokens
//
CREATE INDEX ON :NE(n);
//
CREATE CONSTRAINT ON (n:NE_PERSON) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_LOCATION) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_ORGANIZATION) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_MISC) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_MONEY) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_NUMBER) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_ORDINAL) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_PERCENT) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_DATE) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_TIME) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_DURATION) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_SET) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_CAUSE_OF_DEATH) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_CITY) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_COUNTRY) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_CRIMINAL_CHARGE) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_EMAIL) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_HANDLE) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_IDEOLOGY) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_NATIONALITY) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_RELIGION) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_STATE_OR_PROVINCE) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_TITLE) ASSERT n.t IS UNIQUE;
CREATE CONSTRAINT ON (n:NE_URL) ASSERT n.t IS UNIQUE;
//
// Lemmatized word
//
CREATE CONSTRAINT ON (n:WORD) ASSERT n.l IS UNIQUE;
// - l is the lemma form of the text, it is unique and indexed

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
