// {"impacts": ["permanent alteration", "harmful alteration", "disruption", "death of fish", "temporary alteration", "permanent destruction"],  "reasons": ["dredging", "rip rap", "riprap", "re-sloping", "piles",  "realignment",  "culvert", "rock fill", "fill", "pier", "instream pier", "in-stream pier", "abutment", "berms", "armouring", "concrete pipe", "extension", "channel realignment", "temporary infilling", "coffer dam", "cofferdam", "placement of sand", "spur", "bank protection", "hydraulic impact", "dewatering", "changes to flow", "incidental", "channel deepening", "causeway", "construction"], "nlp_url": "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"}
MERGE (n:PARAM)
    ON CREATE SET 
        n.impacts = apoc.convert.toJson(custom.extract_terms($impacts, $nlp_url)),
        n.reasons = apoc.convert.toJson(custom.extract_terms($reasons, $nlp_url))
RETURN SIZE(n.impacts), SIZE(n.reasons);

// {"path_uid": ["17-HCAA-01501", "17-HCAA-01357", "17-HCAA-01169", "16-HCAA-00219", "17-HCAA-00176", "15-HCAA-01305", "14-HCAA-00498", "16-HCAA-00582", "17-HCAA-00086", "17-HCAA-00033", "18-HCAA-01357", "17-HCAA-01438", "17-HCAA-00066", "17-HCAA-00058", "17-HCAA-00009", "16-HCAA-01754", "16-HCAA-01734", "16-HCAA-01736", "16-HCAA-01612", "16-HCAA-01721", "17-HCAA-01168", "17-HCAA-01046", "14-HCAA-01999", "14-HCAA-01998", "14-HCAA-00904", "14-HCAA-00932", "14-HCAA-00902", "14-HCAA-00292", "17-HCAA-00985", "17-HCAA-01087", "17-HCAA-00808", "17-HCAA-00940", "17-HCAA-00961", "17-HCAA-00963", "15-HCAA-01266", "18-HCAA-01381", "18-HCAA-01379", "18-HCAA-01287", "18-HCAA-01235", "18-HCAA-00950", "18-HCAA-00808", "18-HCAA-00852"], "path_section": "d", "path_item": "proj"}
MATCH (n:PARAM)
WITH apoc.convert.fromJsonList(n.impacts) AS impacts, apoc.convert.fromJsonList(n.reasons) AS reasons
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: $path_section}]-(sentence:SENTENCE)
        WHERE doc.uid IN $path_uid AND r.item <> $path_item
WITH impacts, reasons, doc, sentence 
    MATCH (sentence)-[:HAS_FOOT_PRINT]->(foot_print:FOOT_PRINT),
    (sentence)-[:HAS_KEY_PHRASE]->(key_phrase:KEY_PHRASE)-[:HAS_WORD]->(kword:WORD),
    (sentence)-[:HAS_KEY_PHRASE]->(reason_phrase:KEY_PHRASE)-[:HAS_WORD]->(rword:WORD)
WITH impacts, reasons, doc, sentence, foot_print, key_phrase, reason_phrase,
    COLLECT(kword.lemma) AS kwords, COLLECT(rword.lemma) AS rwords
    WHERE ANY(term IN impacts WHERE apoc.coll.containsAll(kwords, term))
    AND ANY(term IN reasons WHERE apoc.coll.containsAll(rwords, term))
// RETURN COUNT(DISTINCT(doc)) AS doc;
// RETURN DISTINCT(doc) AS doc;
RETURN doc.uid, sentence.text AS sentence, foot_print.text AS foot_print,
    COLLECT(DISTINCT(key_phrase.text)) AS key_phrases, COLLECT(DISTINCT(reason_phrase.text)) AS reason_phrases;

// {"doc_uid": "17", "doc_section": "c", "doc_section_item": "5."}
MATCH (doc:PATH)-[r:HAS_SENTENCE {section: $doc_section}]-(sentence:SENTENCE)
    WHERE doc.uid STARTS WITH $doc_uid AND r.item STARTS WITH $doc_section_item
WITH doc, sentence, r.item AS item
    MATCH (sentence)-[:HAS_NAMED_ENTITY]->(date:NE_DATE)
WITH doc, item, COLLECT(date.text) AS dates
RETURN doc.uid AS doc_uid, item, dates ORDER BY doc_uid, item ASC;
