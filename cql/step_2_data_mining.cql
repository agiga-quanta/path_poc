WITH 
    [ "destruction", "death of fish" ] AS terms,
    "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"  AS stanford_url,
    "http://nltk_nlp:6543/stem"  AS nltk_url
RETURN custom.extract_terms(terms, stanford_url, nltk_url);

WITH
    [
        "destruction",
        "permanent alteration", 
        "harmful alteration", 
        "disruption", 
        "death of fish", 
        "temporary alteration", 
        "permanent destruction"
    ] AS dm1_impacts,
    [
        "infilling",
        "dredging",
        "rip rap",
        "riprap",
        "re-sloping",
        "piles", 
        "realignment",
        "culvert",
        "rock fill",
        "fill",
        "pier",
        "instream pier",
        "in-stream pier",
        "abutment",
        "berms",
        "armouring",
        "concrete pipe",
        "extension",
        "channel realignment",
        "temporary infilling",
        "coffer dam",
        "cofferdam",
        "placement of sand",
        "spur",
        "bank protection",
        "hydraulic impact",
        "dewatering",
        "changes to flow",
        "incidental",
        "channel deepening",
        "causeway",
        "construction"
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

WITH
    [
        // '14-HCAA-00258',
        // '17-HCAA-01168',
        // '14-HCAA-00225',
        '14-HCAA-01139'
    ] AS path_uid_list
MATCH (n:DM1)
WITH
    apoc.convert.fromJsonList(n.dm1_impacts) AS impacts,
    apoc.convert.fromJsonList(n.dm1_reasons) AS reasons,
    path_uid_list
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'd'}]-(sentence:SENTENCE)
        WHERE doc.uid IN path_uid_list AND r.item = 'impact_harm'
RETURN doc, sentence;

MATCH (n:DM1)
WITH 
    apoc.convert.fromJsonList(n.dm1_impacts) AS impacts,
    apoc.convert.fromJsonList(n.dm1_reasons) AS reasons,
    [ 
        // '14-HCAA-00258',
        // '17-HCAA-01168',
        // '14-HCAA-00225',
        '14-HCAA-01139'
    ] AS path_uid_list
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'd'}]-(sentence:SENTENCE)-[:HAS_FOOT_PRINT]->(foot_print:FOOT_PRINT)
        WHERE doc.uid IN path_uid_list AND r.item = 'impact_harm'
WITH impacts, reasons, doc, sentence, foot_print
    MATCH
        (sentence)-[:HAS_KEY_PHRASE]->(key_phrase:KEY_PHRASE)-[:HAS_WORD]->(kword:WORD),
        (sentence)-[:HAS_KEY_PHRASE]->(reason_phrase:KEY_PHRASE)-[:HAS_WORD]->(rword:WORD)
    WHERE key_phrase <> reason_phrase
WITH impacts, reasons, doc, sentence, foot_print, 
    key_phrase, COLLECT(DISTINCT(kword.stem)) AS kwords, reason_phrase, COLLECT(DISTINCT(rword.stem)) AS rwords
    WHERE
        ANY(term IN impacts WHERE apoc.coll.containsAll(kwords, term)) AND
        ANY(term IN reasons WHERE apoc.coll.containsAll(rwords, term))
RETURN doc.uid, sentence.text, foot_print.text, key_phrase.text, kwords, reason_phrase.text, rwords;
