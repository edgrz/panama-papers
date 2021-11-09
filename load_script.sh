export IMPORT_PATH=/import
export HOME=/var/lib/neo4j

echo Data file preprocessing:

tr -d '\\' < $IMPORT_PATH/Addresses.csv > $IMPORT_PATH/Addresses_fixed.csv

sed -e '1,1 s/node_id/node_id:ID(Address)/' < $IMPORT_PATH/Addresses.csv >  /import/Addresses_fixed.csv
sed -e '1,1 s/node_id/node_id:ID(Officer)/' < $IMPORT_PATH/Officers.csv > /import/Officers_fixed.csv
sed -e '1,1 s/node_id/node_id:ID(Entity)/'  < $IMPORT_PATH/Entities.csv > /import/Entities_fixed.csv
sed -e '1,1 s/node_id/node_id:ID(Intermediary)/' < $IMPORT_PATH/Intermediaries.csv > /import/Intermediaries_fixed.csv
sed -e '1 d' < $IMPORT_PATH/all_edges.csv > $IMPORT_PATH/all_edges_fixed.csv

echo Generating relationship headers

for i in Entity Officer Intermediary; do 
   echo "node_id:START_ID($i),detail:IGNORE,node_id:END_ID(Address)" > $IMPORT_PATH/registered_address_$i.csv
done


grep 'registered address' $IMPORT_PATH/all_edges_fixed.csv > $IMPORT_PATH/registered_address.csv


for i in Entity Intermediary; do 
   echo "node_id:START_ID(Officer),detail,node_id:END_ID($i)" > $IMPORT_PATH/officer_of_$i.csv
done

echo Generating relationships

tr '[:upper:]' '[:lower:]' < $IMPORT_PATH/all_edges_fixed.csv | grep -v ',\(intermediary of\|registered address\||related entity\),'  > $IMPORT_PATH/officer_of.csv

for i in Entity; do 
   echo "node_id:START_ID(Intermediary),detail,node_id:END_ID($i)" > $IMPORT_PATH/intermediary_of_$i.csv
done

sed -e 's/,intermediary of,/,,/' < $IMPORT_PATH/all_edges_fixed.csv > $IMPORT_PATH/intermediary_of.csv

echo  Importing ...


$HOME/bin/neo4j-admin import --database=panama2 --nodes=Address=$IMPORT_PATH/Addresses_fixed.csv --nodes=Entity=$IMPORT_PATH/Entities_fixed.csv --nodes=Intermediary=$IMPORT_PATH/Intermediaries_fixed.csv --nodes=Officer=$IMPORT_PATH/Officers_fixed.csv \
           --relationships=REGISTERED_ADDRESS=$IMPORT_PATH/registered_address_Officer.csv,$IMPORT_PATH/registered_address.csv \
           --relationships=REGISTERED_ADDRESS=$IMPORT_PATH/registered_address_Entity.csv,$IMPORT_PATH/registered_address.csv \
           --relationships=REGISTERED_ADDRESS=$IMPORT_PATH/registered_address_Intermediary.csv,$IMPORT_PATH/registered_address.csv \
           --relationships=OFFICER_OF=$IMPORT_PATH/officer_of_Entity.csv,$IMPORT_PATH/officer_of.csv \
           --relationships=OFFICER_OF=$IMPORT_PATH/officer_of_Intermediary.csv,$IMPORT_PATH/officer_of.csv \
           --relationships=INTERMEDIARY_OF=$IMPORT_PATH/intermediary_of_Entity.csv,$IMPORT_PATH/intermediary_of.csv \
           --skip-duplicate-nodes=true --skip-bad-relationships=true --bad-tolerance=10000000 --multiline-fields=true  --ignore-extra-columns=true

echo  Database creation

$HOME/bin/cypher-shell -u "neo4j" -p "test" -d system  'create database panama2;'

echo Statistics
$HOME/bin/cypher-shell -u "neo4j" -p "test" -d panama2 'MATCH (n) RETURN count(*) as nodes;'
$HOME/bin/cypher-shell -u "neo4j" -p "test" -d panama2 'MATCH ()-->() RETURN count(*) as relationships;'
$HOME/bin/cypher-shell -u "neo4j" -p "test" -d panama2 'MATCH (n) RETURN labels(n),count(*) ORDER BY count(*) DESC;'
$HOME/bin/cypher-shell -u "neo4j" -p "test" -d panama2 'MATCH (n)-[r]->(m) RETURN labels(n),type(r),labels(m),count(*) ORDER BY count(*) DESC;'
$HOME/bin/cypher-shell -u "neo4j" -p "test" -d panama2 'MATCH (n)-[r]->(m) RETURN collect(distinct labels(n)),type(r),collect(distinct labels(m)),count(*) ORDER BY count(*) DESC;'
$HOME/bin/cypher-shell -u "neo4j" -p "test" -d panama2 'MATCH (n)-[r]->(m) RETURN collect(distinct labels(n)),type(r),labels(m),count(*) ORDER BY count(*) DESC;'
$HOME/bin/cypher-shell -u "neo4j" -p "test" -d panama2 'MATCH (n)-[r]->(m) RETURN labels(n),type(r),collect(distinct labels(m)),count(*) ORDER BY count(*) DESC;'
$HOME/bin/cypher-shell -u "neo4j" -p "test" -d panama2 'MATCH ()-[r]->() RETURN type(r),r.detail,count(*) ORDER BY count(*) DESC;'
