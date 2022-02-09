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
    impact_phrase, COLLECT(DISTINCT(iword.stem)) AS iwords, 
    reason_phrase, COLLECT(DISTINCT(rword.stem)) AS rwords
    WHERE
        ANY(term IN impact_terms WHERE apoc.coll.containsAll(iwords, term)) AND
        ANY(term IN reason_terms WHERE apoc.coll.containsAll(rwords, term))
RETURN 
    doc.uid AS path_uid, 
    sentence.text AS sentence,
    COLLECT(DISTINCT(foot_print.text)) AS foot_prints,
    COLLECT(DISTINCT(impact_phrase.text)) AS impact_phrases, 
    COLLECT(DISTINCT(reason_phrase.text)) AS reason_phrases; 
//
////////////////////////////////////////////////////////////////////////
