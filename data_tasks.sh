#!/bin/bash

if [ $# -lt 5 ]; then
  echo "Usage: ./data_tasks.sh <COMMANDS> <NEO4J_CONTAINER> <USER_NAME> <PASSWORD> <BOLT_URL> "
  echo "  COMMAND: "
  echo "      t: test if database ready"
  echo "      c: clear the database"
  echo "      rs: remove schema"
  echo "      as: add schema"
  echo "  EXAMPLES:"
  echo "      ./data_tasks.sh t: test if database ready"
  echo "      ./data_tasks.sh c: clear the database"
  echo "      ./data_tasks.sh rs: remove schema"
  echo "      ./data_tasks.sh as: add schema"
  echo "  NEO4J_CONTAINER: the name of the running container, e.g. neo4j"
  echo "  USER_NAME: username to access neo4j database, e.g neo4j"
  echo "  PASSWORD: password to access neo4j database, e.g path_poc"
  echo "  BOLT_URL: Bolt-based URL to access neo4j database, e.g bolt://localhost:7687"
  echo "  EXAMPLES:"
  echo "      ./data_tasks.sh t neo4j neo4j path_poc bolt://localhost:7687"
  exit
fi

res1=$(date +%s)

commands=$1

if [[ $commands == *"t"* ]]; then
  printf "Test if neo4j database is ready ...\n"
  (docker exec -i $2 /var/lib/neo4j/bin/cypher-shell -u $3 -p $4 -a $5) < cql/step_1_test_db.cql
  printf "Done.\n"
fi

if [[ $commands == *"c"* ]]; then
  printf "Clear database ...\n"
  (docker exec -i $2 /var/lib/neo4j/bin/cypher-shell -u $3 -p $4 -a $5) < cql/step_2_clear_db.cql
  printf "Done.\n"
fi

if [[ $commands == *"rs"* ]]; then
  printf "Remove schema ...\n"
  (docker exec -i $2 /var/lib/neo4j/bin/cypher-shell -u $3 -p $4 -a $5) < cql/step_3_remove_schema.cql
  printf "Done.\n"
fi

if [[ $commands == *"as"* ]]; then
  printf "Add schema ...\n"
  (docker exec -i $2 /var/lib/neo4j/bin/cypher-shell -u $3 -p $4 -a $5) < cql/step_4_add_schema.cql
  printf "Done.\n"
fi

res2=$(date +%s)
diff=`echo $((res2-res1)) | awk '{printf "%02dh:%02dm:%02ds\n",int($1/3600),int($1%3600/60),int($1%60)}'`
printf "\nDONE. Total processing time: %s.\n" $diff
