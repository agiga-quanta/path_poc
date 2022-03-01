////////////////////////////////////////////////////////////////////////
//
// (Part of PoC Case 3) Process and store letter of credit terms
//
WITH
    [
        "letter of credit"
    ] AS loc_terms,
    "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"  AS stanford_url,
    "http://nltk_nlp:6543/stem"  AS nltk_url
MERGE (n:DM3)
    SET 
        n.loc_terms = apoc.convert.toJson(custom.run_nlp(loc_terms, stanford_url, nltk_url))
RETURN
    apoc.convert.fromJsonList(n.loc_terms) AS number_of_terms;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// PoC Case 3: Demonstrate 
//
WITH
    [
        '14-HCAA-00225',
        '14-HCAA-01139',
        '14-HCAA-00258',
        '17-HCAA-01168'
    ] AS path_uid_list
MERGE (n:DM3)
    SET n.path_uid_list = path_uid_list
RETURN SIZE(path_uid_list) AS number_of_paths;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// (Part of PoC Case 3)
// - identiy sentences
// - from section 4. (likely 4.1) where there is a 'letter of credit' phrase
//
MATCH (n:DM3)
WITH 
    apoc.convert.fromJsonList(n.loc_terms) AS dm3_terms,
    [
        '14-HCAA-00225',
        '14-HCAA-01139',
        '14-HCAA-00258',
        '17-HCAA-01168'
    ] AS path_uid_list
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'c'}]-(sentence:SENTENCE)
        WHERE doc.uid IN path_uid_list AND r.item STARTS WITH '4.'
WITH dm3_terms, doc, sentence
    MATCH (sentence)-[:HAS_KEY_PHRASE]->(loc_phrase:KEY_PHRASE)-[:HAS_WORD]->(word:WORD)
WITH dm3_terms, doc, sentence, COLLECT(DISTINCT(word.stem)) AS words
    WHERE ANY(term IN dm3_terms WHERE apoc.coll.containsAll(words, [e IN term | e[0]]))
RETURN doc, sentence;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// PoC Case 3: Demonstrate
// - extracting credit (money quantity)
// - from section 4. (likely 4.1) where there is a 'letter of credit' phrase
//
MATCH (n:DM3)
WITH 
    apoc.convert.fromJsonList(n.loc_terms) AS dm3_terms,
    n.path_uid_list AS path_uid_list
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'c'}]-(sentence:SENTENCE)
        WHERE CASE SIZE(path_uid_list) > 0 WHEN TRUE THEN doc.uid IN path_uid_list ELSE TRUE END AND 
            r.item STARTS WITH '4.'
WITH dm3_terms, doc, sentence
    MATCH (sentence)-[:HAS_KEY_PHRASE]->(loc_phrase:KEY_PHRASE)-[:HAS_WORD]->(word:WORD)
WITH dm3_terms, doc, sentence, COLLECT(DISTINCT(word.stem)) AS words
    WHERE ANY(term IN dm3_terms WHERE apoc.coll.containsAll(words, [e IN term | e[0]]))
WITH doc, sentence
    OPTIONAL MATCH (sentence)-[:HAS_NAMED_ENTITY]->(entity:NE_MONEY)
WITH doc, sentence, COLLECT(DISTINCT(entity.text)) AS credits
WITH doc, sentence, credits,
    CASE SIZE(credits) = 0  WHEN TRUE THEN sentence.text ELSE credits[0] END AS credit
RETURN doc.uid AS path_uid, credit, sentence.text AS sentence;
//
////////////////////////////////////////////////////////////////////////
