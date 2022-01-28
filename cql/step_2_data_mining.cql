{"dm1_impacts": ["permanent alteration", "harmful alteration", "disruption", "death of fish", "temporary alteration", "permanent destruction"],  "dm1_reasons": ["dredging", "rip rap", "riprap", "re-sloping", "piles",  "realignment",  "culvert", "rock fill", "fill", "pier", "instream pier", "in-stream pier", "abutment", "berms", "armouring", "concrete pipe", "extension", "channel realignment", "temporary infilling", "coffer dam", "cofferdam", "placement of sand", "spur", "bank protection", "hydraulic impact", "dewatering", "changes to flow", "incidental", "channel deepening", "causeway", "construction"], "dm1_path_uid_list": ["17-HCAA-01501", "17-HCAA-01357", "17-HCAA-01169", "16-HCAA-00219", "17-HCAA-00176", "15-HCAA-01305", "14-HCAA-00498", "16-HCAA-00582", "17-HCAA-00086", "17-HCAA-00033", "18-HCAA-01357", "17-HCAA-01438", "17-HCAA-00066", "17-HCAA-00058", "17-HCAA-00009", "16-HCAA-01754", "16-HCAA-01734", "16-HCAA-01736", "16-HCAA-01612", "16-HCAA-01721", "17-HCAA-01168", "17-HCAA-01046", "14-HCAA-01999", "14-HCAA-01998", "14-HCAA-00904", "14-HCAA-00932", "14-HCAA-00902", "14-HCAA-00292", "17-HCAA-00985", "17-HCAA-01087", "17-HCAA-00808", "17-HCAA-00940", "17-HCAA-00961", "17-HCAA-00963", "15-HCAA-01266", "18-HCAA-01381", "18-HCAA-01379", "18-HCAA-01287", "18-HCAA-01235", "18-HCAA-00950", "18-HCAA-00808", "18-HCAA-00852"], "dm1_path_section": "d", "dm1_path_not_item": "proj", "nlp_url": "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"}

MERGE (n:DM1)
    SET 
        n.dm1_impacts = apoc.convert.toJson(custom.extract_terms($dm1_impacts, $nlp_url)),
        n.dm1_reasons = apoc.convert.toJson(custom.extract_terms($dm1_reasons, $nlp_url)),
        n.dm1_path_uid_list = apoc.convert.toJson($dm1_path_uid_list),
        n.dm1_path_section = 'd',
        n.dm1_path_not_item = 'proj'
RETURN SIZE(apoc.convert.fromJsonList(n.dm1_impacts)) AS impacts, SIZE(apoc.convert.fromJsonList(n.dm1_reasons)) AS reasons, SIZE(apoc.convert.fromJsonList(n.dm1_path_uid_list)) AS paths, n.dm1_path_section AS section, n.dm1_path_not_item AS not_item

//{"dm2_doc_uid": "17", "dm_2_doc_section": "c", "dm2_doc_section_item": "5."}
MERGE (n:DM2)
    SET 
        n.dm2_doc_uid = $dm2_doc_uid,
        n.dm_2_doc_section = $dm_2_doc_section,
        n.dm2_doc_section_item = $dm2_doc_section_item
RETURN n.dm2_doc_uid AS uid_starts_with, n.dm_2_doc_section AS path_section, n.dm2_doc_section_item AS item

MATCH (n:DM1)
WITH apoc.convert.fromJsonList(n.dm1_impacts) AS impacts, apoc.convert.fromJsonList(n.dm1_reasons) AS reasons, apoc.convert.fromJsonList(n.dm1_path_uid_list) AS path_uid_list, n.dm1_path_section AS path_section, n.dm1_path_not_item AS path_not_item
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: path_section}]-(sentence:SENTENCE)
        WHERE doc.uid IN path_uid_list AND r.item <> path_not_item
WITH impacts, reasons, doc, sentence 
    MATCH (sentence)-[:HAS_FOOT_PRINT]->(foot_print:FOOT_PRINT),
    (sentence)-[:HAS_KEY_PHRASE]->(key_phrase:KEY_PHRASE)-[:HAS_WORD]->(kword:WORD),
    (sentence)-[:HAS_KEY_PHRASE]->(reason_phrase:KEY_PHRASE)-[:HAS_WORD]->(rword:WORD)
WITH impacts, reasons, doc, sentence, foot_print, key_phrase, reason_phrase,
    COLLECT(kword.lemma) AS kwords, COLLECT(rword.lemma) AS rwords
    WHERE ANY(term IN impacts WHERE apoc.coll.containsAll(kwords, term))
    AND ANY(term IN reasons WHERE apoc.coll.containsAll(rwords, term))
RETURN COUNT(DISTINCT(doc));

MATCH (n:DM1)
WITH apoc.convert.fromJsonList(n.dm1_impacts) AS impacts, apoc.convert.fromJsonList(n.dm1_reasons) AS reasons, apoc.convert.fromJsonList(n.dm1_path_uid_list) AS path_uid_list, n.dm1_path_section AS path_section, n.dm1_path_not_item AS path_not_item
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: path_section}]-(sentence:SENTENCE)
        WHERE doc.uid IN path_uid_list AND r.item <> path_not_item
WITH impacts, reasons, doc, sentence 
    MATCH (sentence)-[:HAS_FOOT_PRINT]->(foot_print:FOOT_PRINT),
    (sentence)-[:HAS_KEY_PHRASE]->(key_phrase:KEY_PHRASE)-[:HAS_WORD]->(kword:WORD),
    (sentence)-[:HAS_KEY_PHRASE]->(reason_phrase:KEY_PHRASE)-[:HAS_WORD]->(rword:WORD)
WITH impacts, reasons, doc, sentence, foot_print, key_phrase, reason_phrase,
    COLLECT(kword.lemma) AS kwords, COLLECT(rword.lemma) AS rwords
    WHERE ANY(term IN impacts WHERE apoc.coll.containsAll(kwords, term))
    AND ANY(term IN reasons WHERE apoc.coll.containsAll(rwords, term))
RETURN doc.uid, sentence.text AS sentence, foot_print.text AS foot_print,
    COLLECT(DISTINCT(key_phrase.text)) AS key_phrases, COLLECT(DISTINCT(reason_phrase.text)) AS reason_phrases;

MATCH (n:DM1)
WITH apoc.convert.fromJsonList(n.dm1_impacts) AS impacts, apoc.convert.fromJsonList(n.dm1_reasons) AS reasons, apoc.convert.fromJsonList(n.dm1_path_uid_list) AS path_uid_list, n.dm1_path_section AS path_section, n.dm1_path_not_item AS path_not_item
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: path_section}]-(sentence:SENTENCE)
        WHERE doc.uid IN path_uid_list AND r.item <> path_not_item
WITH impacts, reasons, doc, sentence 
    MATCH (sentence)-[:HAS_FOOT_PRINT]->(foot_print:FOOT_PRINT),
    (sentence)-[:HAS_KEY_PHRASE]->(key_phrase:KEY_PHRASE)-[:HAS_WORD]->(kword:WORD),
    (sentence)-[:HAS_KEY_PHRASE]->(reason_phrase:KEY_PHRASE)-[:HAS_WORD]->(rword:WORD)
WITH impacts, reasons, doc, sentence, foot_print, key_phrase, reason_phrase,
    COLLECT(kword.lemma) AS kwords, COLLECT(rword.lemma) AS rwords
    WHERE ANY(term IN impacts WHERE apoc.coll.containsAll(kwords, term))
    AND ANY(term IN reasons WHERE apoc.coll.containsAll(rwords, term))
RETURN DISTINCT(doc) AS doc;

MATCH (n:DM2)
WITH n.dm2_doc_uid AS dm2_doc_uid, n.dm_2_doc_section AS dm2_doc_section, n.dm2_doc_section_item AS dm2_doc_section_item
MATCH (doc:PATH)-[r:HAS_SENTENCE {section: dm2_doc_section}]-(sentence:SENTENCE)
    WHERE doc.uid STARTS WITH dm2_doc_uid AND r.item STARTS WITH dm2_doc_section_item
WITH doc, sentence, r.item AS item
    MATCH (sentence)-[:HAS_NAMED_ENTITY]->(date:NE_DATE)
RETURN COUNT(DISTINCT(doc.uid));

MATCH (n:DM2)
WITH n.dm2_doc_uid AS dm2_doc_uid, n.dm_2_doc_section AS dm2_doc_section, n.dm2_doc_section_item AS dm2_doc_section_item
MATCH (doc:PATH)-[r:HAS_SENTENCE {section: dm2_doc_section}]-(sentence:SENTENCE)
    WHERE doc.uid STARTS WITH dm2_doc_uid AND r.item STARTS WITH dm2_doc_section_item
WITH doc, sentence, r.item AS item
    MATCH (sentence)-[:HAS_NAMED_ENTITY]->(date:NE_DATE)
WITH doc, item, COLLECT(date.text) AS dates
RETURN doc.uid AS doc_uid, item, dates ORDER BY doc_uid, item ASC;
