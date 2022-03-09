////////////////////////////////////////////////////////////////////////
//
// (Part of PoC Case 1) Process and store impact and reason (cause) terms
//
WITH
    [
        "death of fish",
        "destroy",
        "destruction",
        "disruption", 
        "harmful alteration", 
        "kill",
        "loss",
        "permanent alteration", 
        "permanent destruction",
        "temporary alteration"
    ] AS impacts,
    [
        "abutment",
        "armouring",
        "bank protection",
        "bank stabilization",
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
    ] AS reasons,
    "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"  AS stanford_url,
    "http://nltk_nlp:6543/stem"  AS nltk_url
MERGE (n:DM1)
    SET 
        n.impacts = apoc.convert.toJson(custom.run_nlp(impacts, stanford_url, nltk_url)),
        n.reasons = apoc.convert.toJson(custom.run_nlp(reasons, stanford_url, nltk_url))
RETURN
    SIZE(apoc.convert.fromJsonList(n.impacts)) AS dm1_impacts,
    SIZE(apoc.convert.fromJsonList(n.reasons)) AS dm1_reasons;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// (Part of PoC Case 1) Demonstrate capturing foot print in 
// - the impact_harm item of the description section
//
WITH
    [
        '14-HCAA-00225',
        '14-HCAA-01139',
        '14-HCAA-00258',
        '17-HCAA-01168'
    ] AS path_uid_list
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'd'}]-(sentence:SENTENCE)
        WHERE doc.uid IN path_uid_list AND r.item = 'impact_harm'
RETURN doc, sentence;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// PoC Case 1: Demonstrate 
// - capturing impact and reason terms 
// - for existing foot print 
// - in the impact_harm item of the description section
//
MATCH (n:DM1)
WITH 
    apoc.convert.fromJsonList(n.impacts) AS dm1_impacts,
    apoc.convert.fromJsonList(n.reasons) AS dm1_reasons,
    n.path_uid_list AS path_uid_list
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'd'}]-(sentence:SENTENCE)-[:HAS_NAMED_ENTITY]->(foot_print:NE_FOOTPRINT)
        WHERE CASE SIZE(path_uid_list) > 0 WHEN TRUE THEN doc.uid IN path_uid_list ELSE TRUE END AND 
			r.item = 'impact_harm'
WITH dm1_impacts, dm1_reasons, doc, sentence, foot_print
    MATCH
        (sentence)-[:HAS_KEY_PHRASE]->(impact_phrase:KEY_PHRASE)-[:HAS_WORD]->(iword:WORD),
        (sentence)-[:HAS_KEY_PHRASE]->(reason_phrase:KEY_PHRASE)-[:HAS_WORD]->(rword:WORD)
    WHERE impact_phrase <> reason_phrase
WITH dm1_impacts, dm1_reasons, doc, sentence, foot_print, 
    COLLECT(DISTINCT(iword.stem)) AS iwords, COLLECT(DISTINCT(rword.stem)) AS rwords
    WHERE
        ANY(term IN dm1_impacts WHERE apoc.coll.containsAll(iwords, [e IN term | e[0]])) AND
        ANY(term IN dm1_reasons WHERE apoc.coll.containsAll(rwords, [e IN term | e[0]]))
WITH dm1_impacts, dm1_reasons, doc, sentence, foot_print, 
    COLLECT(DISTINCT(iwords)) AS impact_phrases,
    COLLECT(DISTINCT(rwords)) AS reason_phrases
WITH dm1_impacts, dm1_reasons, doc, sentence, foot_print, 
    REDUCE(r = [], term IN dm1_impacts | 
        CASE ANY(phrase IN impact_phrases WHERE apoc.coll.containsAll(phrase, [e IN term | e[0]]))
            WHEN TRUE THEN r + [[e IN term | e[1]]] ELSE r END
    ) AS impact_phrases,
    REDUCE(r = [], term IN dm1_reasons | 
        CASE ANY(phrase IN reason_phrases WHERE apoc.coll.containsAll(phrase, [e IN term | e[0]]))
            WHEN TRUE THEN r + [[e IN term | e[1]]] ELSE r END
    ) AS reason_phrases
 WITH
    [
        'NE_LOCATION', 
        'NE_ORGANIZATION', 
        'NE_PERSON', 
        'NE_TITLE',
        'NE_BUILDING',
        'NE_ECOLOGY',
        'NE_WATERBODY'
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

