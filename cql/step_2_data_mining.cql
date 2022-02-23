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
// (Part of PoC Case 1) Process and store impact and reason (cause) terms
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
    ] AS impacts,
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
    ] AS reasons,
    "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"  AS stanford_url,
    "http://nltk_nlp:6543/stem"  AS nltk_url
MERGE (n:DM1)
    SET 
        n.impacts = apoc.convert.toJson(custom.extract_terms(impacts, stanford_url, nltk_url)),
        n.reasons = apoc.convert.toJson(custom.extract_terms(reasons, stanford_url, nltk_url))
RETURN
    apoc.convert.fromJsonList(n.impacts) AS dm1_impacts,
    apoc.convert.fromJsonList(n.reasons) AS dm1_reasons;
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
MATCH (n:DM1)
WITH
    apoc.convert.fromJsonList(n.impacts) AS dm1_impacts,
    apoc.convert.fromJsonList(n.reasons) AS dm1_reasons,
    path_uid_list
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
    [ 
        '14-HCAA-00225',
        '14-HCAA-01139',
        '14-HCAA-00258',
        '17-HCAA-01168'
    ] AS path_uid_list
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'd'}]-(sentence:SENTENCE)-[:HAS_NAMED_ENTITY]->(foot_print:NE_FOOTPRINT)
        WHERE doc.uid IN path_uid_list AND r.item = 'impact_harm'
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

////////////////////////////////////////////////////////////////////////
//
// (Part of PoC Case 3) Process and store letter of credit terms
//
WITH
    [
        "letter of credit"
    ] AS terms,
    "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"  AS stanford_url,
    "http://nltk_nlp:6543/stem"  AS nltk_url
MERGE (n:DM3)
    SET 
        n.terms = apoc.convert.toJson(custom.extract_terms(terms, stanford_url, nltk_url))
RETURN
    apoc.convert.fromJsonList(n.terms) AS dm3_terms;
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
    apoc.convert.fromJsonList(n.terms) AS dm3_terms,
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
    apoc.convert.fromJsonList(n.terms) AS dm3_terms,
    [
        '14-HCAA-00225',
        '14-HCAA-00258',
        '14-HCAA-01139',
        '17-HCAA-01168'
    ] AS path_uid_list
    MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'c'}]-(sentence:SENTENCE)
        WHERE doc.uid IN path_uid_list AND r.item STARTS WITH '4.'
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

////////////////////////////////////////////////////////////////////////
//
// (Part of PoC Case 4) Demonstrate
// - look up documents 
// - has (i) 'conditions for offsettings'
// - (ii) has 'scale and desctiption of offsetting measures',
//      if absent then use the first bullet after (i)
// - (iii) has 'contingency measures'
//      if absent then use the first bullet before the next bullet at the same level with (i)
// - extract all bullets between (ii) (inclusive) and (iii) (exclusive).
//
WITH 
    [
        '13-HCAA-CA1-00850',
        '13-HCAA-CA1-00891',
        '14-HCAA-00225',
        '14-HCAA-00258',
        '14-HCAA-01139',
        '15-HCAA-00124',
        '15-HCAA-00279',
        '15-HCAA-01013',
        '16-HCAA-01202',
        '16-HCAA-01206',
        '17-HCAA-01168'
    ] AS path_uid_list
MATCH (doc:PATH)-[r:HAS_SENTENCE {section: 'c'}]-(s:SENTENCE)
    WHERE 
        doc.uid IN path_uid_list AND
        s.text =~ 'Conditions\\s+that\\s+relate\\s+to(\\s+the)?\\s+(compensation|(habitat\\s+)?offsett?ing)(\\s+(for|of)(\\s+the\\s+serious\\s+(b|h)arm\\s+to\\s+(f|F)ish(\\s+and\\s+impacts\\s+(on|to)\\s+aquatic\\s+species\\s+at\\s+risk)?\\s+likely\\s+to\\s+result\\s+from)?\\s+the\\s+authorized\\s+work,\\s+undertaking\\s+or\\s+activity(\\s+that\\s+results\\s+in\\s+impacts\\s+to\\s+fish(\\s+and\\s+fish)?\\s+habitat)?)?\\:?'
WITH doc, r.item AS ri
    MATCH (doc)-[r:HAS_SENTENCE {section: 'c'}]-(s:SENTENCE)
        WHERE r.item STARTS WITH ri AND r.item <> ri
WITH doc, apoc.coll.sort(COLLECT(DISTINCT(r.item))) AS rc
    OPTIONAL MATCH
        (doc)-[r1:HAS_SENTENCE {section: 'c'}]-(s1:SENTENCE),
        (doc)-[r2:HAS_SENTENCE {section: 'c'}]-(s2:SENTENCE)
        WHERE 
            r1.item IN rc AND 
            s1.text =~ 'Scale\\s+and\\s+description\\s+of\\s+offsetting\\s+measures.*' AND
            r2.item IN rc AND
            s2.text =~ 'Contingency\\s+measures.*'           
WITH doc, rc, COLLECT(DISTINCT(r1.item)) AS r1c, COLLECT(DISTINCT(r2.item)) AS r2c
WITH doc, rc,
    REDUCE(r = HEAD(r1c), e IN r1c | CASE e < r WHEN TRUE THEN e ELSE r END) AS r1,
    REDUCE(r = HEAD(r2c), e IN r2c | CASE e < r WHEN TRUE THEN e ELSE r END) AS r2
WITH doc, r1, r2, 
    CASE 
        WHEN r1 IS NULL AND r2 IS NULL THEN rc
        WHEN r1 IS NULL AND r2 IS NOT NULL THEN 
            REDUCE(r = [], e IN rc | CASE e < r2  WHEN TRUE THEN r + [e] ELSE r END)
        WHEN r1 IS NOT NULL AND r2 IS NULL THEN 
            REDUCE(r = [], e IN rc | CASE e >= r1  WHEN TRUE THEN r + [e] ELSE r END)
        ELSE 
            REDUCE(r = [], e IN rc | CASE e >= r1 AND e < r2  WHEN TRUE THEN r + [e] ELSE r END)
    END AS rc
WITH doc, rc
    MATCH (doc)-[r:HAS_SENTENCE {section: 'c'}]-(s:SENTENCE)
        WHERE r.item IN rc
RETURN doc, s ORDER BY r.i ASC;
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
WITH
    [
        "anchored tree root wads",
        "baseline measurements",
        "boulder bench",
        "channels",
        "clean large boulders",
        "clean rock",
        "concrete box culverts",
        "discussions",
        "embedded woody habitat structure",
        "existing bottom substrate",
        "fish habitat biologist",
        "fish habitat features",
        "Indigenous community",
        "Indigenous nation",
        "live brush layering",
        "monitoring program",
        "monitoring",
        "new culverts",
        "new stream channel",
        "offsetting measures",
        "offsetting plan",
        "open water ponds",
        "post-construction fish habitat conditions",
        "riffle rock sections",
        "riverbed dredged",
        "rock reefs",
        "rock revetment treatments",
        "spawning habitat",
        "stream morphological features",
        "substrate composition",
        "vegetated rip rap",
        "Vegetation",
        "water depths"
    ] AS objects,
    [
        "armouring of culvert inlets",
        "assist in the placement",
        "backwater pools and flats",
        "bank stability",
        "baseline measurements of fish habitat present",
        "cover and diversity",
        "create artificial spawning areas",
        "extent of HADD",
        "food production",
        "food supply",
        "habitat diversity",
        "improved fish passage",
        "in-stream cover",
        "increase the abundance of invertebrates",
        "increase the diversity of invertebrates",
        "increase the quality of invertebrates",
        "increase the overall understanding of aquatic ecology",
        "invertebrate food production",
        "nearshore habitat features",
        "provide food production habitat",
        "riffle condition ",
        "increase the diversity of cover habitats",
        "substrate diversity "
    ] AS goals,
    [
        "be onsite",
        "conduct",
        "confirm",
        "construct",
        "construction",
        "create",
        "creation",
        "complete",
        "determining",
        "develop",
        "engage",
        "enhancement",
        "establish",
        "implement",
        "implement",
        "incorporation",
        "install",
        "installation",
        "place",
        "reconstruction",
        "removal",
        "report",
        "undertake",
        "verify"
    ] AS actions,
    "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"  AS stanford_url,
    "http://nltk_nlp:6543/stem"  AS nltk_url
MERGE (n:DM4)
    SET 
        n.objects = apoc.convert.toJson(custom.extract_terms(objects, stanford_url, nltk_url)),
        n.goals = apoc.convert.toJson(custom.extract_terms(goals, stanford_url, nltk_url)),
        n.actions = apoc.convert.toJson(custom.extract_terms(actions, stanford_url, nltk_url))
RETURN
    apoc.convert.fromJsonList(n.objects) AS d4_objects,
    apoc.convert.fromJsonList(n.goals) AS d4_goals,
    apoc.convert.fromJsonList(n.goals) AS d4_actions;
//
////////////////////////////////////////////////////////////////////////
