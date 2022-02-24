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
