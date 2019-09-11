MONGO_VERSION=3.6
NETWORK_NAME="primary_net"

MONGOS1_SRC="mongos1"
MONGOS1_DEST="backup-mongos1"
MONGOS1_PORT=27017
DATABASE="test_db"
COLLECTION="test_col"

WAIT_TIME=60 # in seconds

# docker-compose -f local-compose.yml up -d && \

# echo "--------------------------------------------------" && \
# echo "waiting for $WAIT_TIME seconds..." && \
# sleep $WAIT_TIME && \

echo "--------------------------------------------------" && \
echo "enabling sharding..." && \
docker run -it --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_SRC:$MONGOS1_PORT" $DATABASE --eval "sh.enableSharding('$DATABASE')" && \

echo "--------------------------------------------------" && \
echo "sharding $DATABASE.$COLLECTION" && \
docker run -it --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_SRC:$MONGOS1_PORT" $DATABASE --eval "sh.shardCollection('$DATABASE.$COLLECTION', {'item_id': 'hashed'})" && \

echo "--------------------------------------------------" && \
echo "enabling sharding..." && \
docker run -it --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_DEST:$MONGOS1_PORT" $DATABASE --eval "sh.enableSharding('$DATABASE')" && \

echo "--------------------------------------------------" && \
echo "sharding $DATABASE.$COLLECTION" && \
docker run -it --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_DEST:$MONGOS1_PORT" $DATABASE --eval "sh.shardCollection('$DATABASE.$COLLECTION', {'item_id': 'hashed'})" && \

# echo "--------------------------------------------------" && \
# echo "simulating 10 ingestions from 10 different sources" && \
# for i in $(seq 10); do
# 	echo $i
# 	docker run --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_SRC:$MONGOS1_PORT" $DATABASE --eval "
# 		db.$COLLECTION.insertMany([
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 },
# 			{ item_id: $i, count: 1 }
# 		])
# 	" &
# done && \

# echo "--------------------------------------------------" && \
# echo "waiting for 5 seconds for ingestion..." && \
# sleep 5 && \

# echo "--------------------------------------------------" && \
# echo "incrementing item_id #5 to count 2"
# docker run -it --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_SRC:$MONGOS1_PORT" $DATABASE --eval "
# 	db.$COLLECTION.update(
# 		{ item_id: 5 },
# 		{ \$inc: {count: 1} }
# 	)
# " &&

# echo "--------------------------------------------------" && \
# echo "check increment"
# docker run -it --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_SRC:$MONGOS1_PORT" $DATABASE --eval "
# 	db.$COLLECTION.find(
# 		{ number: 5 }
# 	)
# " &&

echo "--------------------------------------------------" && \
docker run -it --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_SRC:$MONGOS1_PORT" $DATABASE --eval "
	db.$COLLECTION.getShardDistribution()
" &&

echo "--------------------------------------------------" && \
echo "done."
