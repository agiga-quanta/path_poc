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
        n.terms = apoc.convert.toJson(custom.run_nlp(terms, stanford_url, nltk_url))
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
// (Part of PoC Case 4) Input data
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
        n.objects = apoc.convert.toJson(custom.run_nlp(objects, stanford_url, nltk_url)),
        n.goals = apoc.convert.toJson(custom.run_nlp(goals, stanford_url, nltk_url)),
        n.actions = apoc.convert.toJson(custom.run_nlp(actions, stanford_url, nltk_url))
RETURN
    apoc.convert.fromJsonList(n.objects) AS d4_objects,
    apoc.convert.fromJsonList(n.goals) AS d4_goals,
    apoc.convert.fromJsonList(n.goals) AS d4_actions;
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
    MATCH (doc)-[r:HAS_SENTENCE {section: 'c'}]-(sentence:SENTENCE)
        WHERE r.item IN rc
WITH doc, sentence ORDER BY r.i ASC
    MATCH (n:DM4)
WITH doc, sentence,
    apoc.convert.fromJsonList(n.objects) AS d4_objects
        MATCH (sentence)-[:HAS_KEY_PHRASE]->(:KEY_PHRASE)-[:HAS_WORD]->(word:WORD)
WITH d4_objects, doc, sentence, COLLECT(DISTINCT(word.stem)) AS words
    WHERE ANY(term IN d4_objects WHERE apoc.coll.containsAll(words, [e IN term | e[0]]))
WITH d4_objects, doc, sentence, 
    COLLECT(DISTINCT(words)) AS object_phrases
WITH doc, sentence,
    REDUCE(r = [], term IN d4_objects | 
        CASE ANY(phrase IN object_phrases WHERE apoc.coll.containsAll(phrase, [e IN term | e[0]]))
            WHEN TRUE THEN r + [[e IN term | e[1]]] ELSE r END
    ) AS object_phrases
RETURN doc.uid, object_phrases, sentence.text;
//
////////////////////////////////////////////////////////////////////////
