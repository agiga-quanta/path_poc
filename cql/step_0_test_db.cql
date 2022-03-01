////////////////////////////////////////////////////////////////////////
//
CALL dbms.components()
  YIELD name, versions, edition
UNWIND versions AS version
RETURN name, version, edition
UNION 
RETURN "APOC" AS name, apoc.version() AS version, "" AS edition
UNION 
RETURN "GDS" AS name, gds.version() AS version, "" AS edition;
//
////////////////////////////////////////////////////////////////////////
