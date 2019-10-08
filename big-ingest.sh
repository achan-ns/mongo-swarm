MONGO_VERSION=3.6
NETWORK_NAME="primary_net"

MONGOS1_SRC="source-mongos1"
MONGOS1_PORT=27017
DATABASE="test_db"
COLLECTION="test_col"

AMT=10000

echo "simulating ingestion of $AMT elements" && \
docker run -d --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_SRC:$MONGOS1_PORT" $DATABASE --eval "
	for (i = 0; i < $AMT; i++) {
		db.$COLLECTION.insert({
			item_id: i, count: 1
		})
	}
"

echo "--------------------------------------------------" && \
docker run -it --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_SRC:$MONGOS1_PORT" $DATABASE --eval "
	db.$COLLECTION.getShardDistribution()
" &&

echo "--------------------------------------------------" && \
echo "done."
