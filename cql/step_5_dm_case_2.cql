////////////////////////////////////////////////////////////////////////
//
// PoC Case 2: Demonstrate 
// - extract from and to dates
// - from conditions section, item 1.
//
WITH
    [
        '14-HCAA-00225',
        '14-HCAA-00258',
        '14-HCAA-01139',
        '17-HCAA-01168'
    ] AS path_uid_list
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'c', item: '1.'}]-(sentence:SENTENCE)
        WHERE doc.uid IN path_uid_list
WITH doc, sentence
    MATCH (sentence)-[:HAS_NAMED_ENTITY]->(date:NE_DATE)
WITH doc, sentence, COLLECT(DISTINCT(date.text)) AS dates
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

