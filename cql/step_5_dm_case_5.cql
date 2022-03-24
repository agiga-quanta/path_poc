////////////////////////////////////////////////////////////////////////
//
// (Part of PoC Case 5) Input terms
//
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
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// PoC Case 5: Input - List of Authorization UIDs 
//
WITH
    [
        '16-HCAA-01734',
        '17-HCAA-00829',
        '18-HCAA-00253'
    ] AS path_uid_list
MERGE (n:DM5)
    SET n.path_uid_list = path_uid_list
RETURN SIZE(path_uid_list) AS path_uid_list;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Looking for bullet 5. of the PATH doc
//
MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'c'}]-(s:SENTENCE)
    WHERE r.item IN ['5.']
RETURN DISTINCT(s.text), COUNT(*);
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Compose a regular expression for the bullet
//
MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'c'}]-(s:SENTENCE)
    WHERE SIZE(r.item) = 2 AND
        s.text =~ 'Conditions\\s+that\\s+relate\\s+to\\s+monitoring\\s+and\\s+reporting\\s+of(\\s+implementation\\s+of)?\\s+(offsetting\\s+measures|compensation|habitat\\s+offsets).*'
RETURN DISTINCT(s.text), COUNT(*) AS count, COLLECT(DISTINCT(r.item)) AS bullets;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// (Part of PoC Case 5) Demonstrate
// - look up documents 
// - has (i) 'Conditions that relate to monitoring and reporting of implementation of offsetting measures'
// - extract sentences with dates
// - and predefined key phrases if any
//
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
//
////////////////////////////////////////////////////////////////////////
