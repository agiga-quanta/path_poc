////////////////////////////////////////////////////////////////////////
//
// Export the database, plus indexes, as Neo4j-browser-friendly cyphers
//
CALL apoc.export.cypher.all("all-plain.cypher", {
    format: "plain",
    useOptimizations: {type: "UNWIND_BATCH", unwindBatchSize: 20}
})
YIELD file, batches, source, format, nodes, relationships, properties, time, rows, batchSize
RETURN file, batches, source, format, nodes, relationships, properties, time, rows, batchSize;
//
////////////////////////////////////////////////////////////////////////
