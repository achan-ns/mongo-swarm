MONGO_VERSION=3.6
NETWORK_NAME="primary_net"

MONGOS1_SRC="mongos1"
MONGOS1_DEST="backup-mongos1"
MONGOS1_PORT=27017
DATABASE="test_db"
COLLECTION="test_col"

WAIT_TIME=60 # in seconds

echo "--------------------------------------------------" && \
echo "Balancer State on SRC":
docker run -it --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_SRC:$MONGOS1_PORT" $DATABASE --eval "
	sh.getBalancerState()
" &&

echo "--------------------------------------------------" && \
echo "Shard Distribution on SRC":
docker run -it --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_SRC:$MONGOS1_PORT" $DATABASE --eval "
	db.$COLLECTION.getShardDistribution()
" &&

echo "--------------------------------------------------" && \
echo "Shard Distribution on DEST":
docker run -it --rm --network $NETWORK_NAME mongo:$MONGO_VERSION mongo --host "$MONGOS1_DEST:$MONGOS1_PORT" $DATABASE --eval "
	db.$COLLECTION.getShardDistribution()
" &&

echo "--------------------------------------------------" && \
echo "done."
