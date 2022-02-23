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