////////////////////////////////////////////////////////////////////////
//
// Test connectivity from neo4j to stanford_nlp and nltk_nlp
//
WITH 
    [ "destruction", "death of fish" ] AS terms,
    "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"  AS stanford_url,
    "http://nltk_nlp:6543/stem"  AS nltk_url
RETURN custom.extract_terms(terms, stanford_url, nltk_url);
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Process and store impact and reason (cause) terms
//
WITH
    [
        "death of fish", 
        "destruction",
        "disruption", 
        "harmful alteration", 
        "kill",
        "loss",
        "permanent alteration", 
        "permanent destruction",
        "temporary alteration"
    ] AS dm1_impacts,
    [
        "abutment",
        "armouring",
        "bank protection",
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
    ] AS dm1_reasons,
    "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"  AS stanford_url,
    "http://nltk_nlp:6543/stem"  AS nltk_url
MERGE (n:DM1)
    SET 
        n.dm1_impacts = apoc.convert.toJson(custom.extract_terms(dm1_impacts, stanford_url, nltk_url)),
        n.dm1_reasons = apoc.convert.toJson(custom.extract_terms(dm1_reasons, stanford_url, nltk_url))
RETURN
    SIZE(apoc.convert.fromJsonList(n.dm1_impacts)) AS impacts,
    SIZE(apoc.convert.fromJsonList(n.dm1_reasons)) AS reasons;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Demonstrate capturing foot print in 
// - the impact_harm item of the description section
//
WITH
    [
        '14-HCAA-00225',
        '14-HCAA-01139',
        '14-HCAA-00258',
        '17-HCAA-01168'
    ] AS path_uid_list
MATCH (n:DM1)
WITH
    apoc.convert.fromJsonList(n.dm1_impacts) AS impacts,
    apoc.convert.fromJsonList(n.dm1_reasons) AS reasons,
    path_uid_list
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'd'}]-(sentence:SENTENCE)
        WHERE doc.uid IN path_uid_list AND r.item = 'impact_harm'
RETURN doc, sentence;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Demonstrate 
// - capturing impact and reason terms 
// - for existing foot print 
// - in the impact_harm item of the description section
//
MATCH (n:DM1)
WITH 
    apoc.convert.fromJsonList(n.dm1_impacts) AS impact_terms,
    apoc.convert.fromJsonList(n.dm1_reasons) AS reason_terms,
    [ 
        '14-HCAA-00225',
        '14-HCAA-01139',
        '14-HCAA-00258',
        '17-HCAA-01168'
    ] AS path_uid_list
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'd'}]-(sentence:SENTENCE)-[:HAS_FOOT_PRINT]->(foot_print:FOOT_PRINT)
        WHERE doc.uid IN path_uid_list AND r.item = 'impact_harm'
WITH impact_terms, reason_terms, doc, sentence, foot_print
    MATCH
        (sentence)-[:HAS_KEY_PHRASE]->(impact_phrase:KEY_PHRASE)-[:HAS_WORD]->(iword:WORD),
        (sentence)-[:HAS_KEY_PHRASE]->(reason_phrase:KEY_PHRASE)-[:HAS_WORD]->(rword:WORD)
    WHERE impact_phrase <> reason_phrase
WITH impact_terms, reason_terms, doc, sentence, foot_print, 
    COLLECT(DISTINCT(iword.stem)) AS iwords, COLLECT(DISTINCT(rword.stem)) AS rwords
    WHERE
        ANY(term IN impact_terms WHERE apoc.coll.containsAll(iwords, [e IN term | e[0]])) AND
        ANY(term IN reason_terms WHERE apoc.coll.containsAll(rwords, [e IN term | e[0]]))
WITH impact_terms, reason_terms, doc, sentence, foot_print, 
    COLLECT(DISTINCT(iwords)) AS impact_phrases,
    COLLECT(DISTINCT(rwords)) AS reason_phrases
WITH impact_terms, reason_terms, doc, sentence, foot_print, 
    REDUCE(r = [], term IN impact_terms | 
        CASE ANY(phrase IN impact_phrases WHERE apoc.coll.containsAll(phrase, [e IN term | e[0]]))
            WHEN TRUE THEN r + [[e IN term | e[1]]] ELSE r END
    ) AS impact_phrases,
    REDUCE(r = [], term IN reason_terms | 
        CASE ANY(phrase IN reason_phrases WHERE apoc.coll.containsAll(phrase, [e IN term | e[0]]))
            WHEN TRUE THEN r + [[e IN term | e[1]]] ELSE r END
    ) AS reason_phrases
 WITH
    [
        'NE_LOCATION', 
        'NE_ORGANIZATION', 
        'NE_PERSON', 
        'NE_TITLE'
    ] AS entity_types,
    doc, sentence, foot_print, impact_phrases, reason_phrases
    OPTIONAL MATCH (sentence)-[:HAS_NAMED_ENTITY]->(entity)
        WHERE SIZE(apoc.coll.intersection(entity_types, LABELS(entity))) > 0
WITH
    doc, sentence, foot_print, impact_phrases, reason_phrases,
    COLLECT(DISTINCT(entity.text)) AS named_entities
RETURN
    doc.uid AS path_uid, COLLECT(DISTINCT(foot_print.text)) AS foot_prints, 
    COLLECT(DISTINCT(impact_phrases)) AS impact_phrases, 
    COLLECT(DISTINCT(reason_phrases)) AS reason_phrases,
    COLLECT(DISTINCT(named_entities)) AS named_entities,
    sentence.text AS sentence;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Demonstrate 
// - extract from and to dates
// - from conditions section, item 1.
//
WITH
    [
        '14-HCAA-00225',
        '14-HCAA-00258',
        '14-HCAA-00645',
        '14-HCAA-01139',
        '16-HCAA-00616',
        '17-HCAA-01168'
    ] AS path_uid_list
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'c', item: '1.'}]-(sentence:SENTENCE)
        WHERE doc.uid IN path_uid_list
WITH doc, sentence
    MATCH (sentence)-[:HAS_NAMED_ENTITY]->(date:NE_DATE)
WITH doc, sentence, COLLECT(date.text) AS dates
WITH doc, sentence, 
    CASE SIZE(dates) = 0 
        WHEN TRUE THEN ['', ''] 
        ELSE 
            CASE SIZE(dates) = 1 
                WHEN TRUE THEN ['Date of Issuance', dates[0]]
                ELSE [dates[0], dates[1]] END
        END AS dates
RETURN doc.uid AS path_uid, dates[0] AS from, dates[1] AS to, sentence.text AS sentence;
//
////////////////////////////////////////////////////////////////////////
