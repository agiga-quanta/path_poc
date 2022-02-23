////////////////////////////////////////////////////////////////////////
//
CALL apoc.custom.asFunction(
    'run_nlp',
    'WITH REDUCE(sentence="", phrase IN $phrase_list | sentence + phrase + ". ") AS sentences
        CALL apoc.load.jsonParams(
            $stanford_url,
            {method: "POST", contentType: "plain/text"},
            sentences
        ) YIELD value AS nlp_sentences
    WITH nlp_sentences 
        CALL apoc.load.jsonParams(
            $nltk_url,
            {method: "POST", contentType: "application/json"},
            apoc.convert.toJson(nlp_sentences)
        ) YIELD value AS stem_sentences
    RETURN 
        REDUCE(
            term_list = [],
            sentence IN stem_sentences.sentences | 
                term_list + [[
                    token IN REVERSE(TAIL(REVERSE(sentence.tokens))) WHERE SIZE(token.stem) > 1 | 
                        [token.stem, token.originalText]
                ]]
        ) AS term_list',
    'LIST OF LIST OF STRING',
    [['phrase_list', 'LIST OF STRING'], ['stanford_url', 'STRING'], ['nltk_url', 'STRING']],
    TRUE,
    'Natural language process a list of terms into list of lemmatized words.'
);
//
// Clear cache
//
CALL db.clearQueryCaches();
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// Test run_nlp
//
WITH 
    [ "destruction", "death of fish" ] AS phrase_list,
    "http://stanford_nlp:9000/?properties={'outputFormat':'json'}"  AS stanford_url,
    "http://nltk_nlp:6543/stem"  AS nltk_url
RETURN custom.run_nlp(phrase_list, stanford_url, nltk_url);
//
////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////
//
// List all custom queries
//
CALL apoc.custom.list();
//
////////////////////////////////////////////////////////////////////////
