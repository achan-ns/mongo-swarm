IP="10.57.1.48" # use ifconfig

MONGOS1_PORT=20111
MONGOS2_PORT=20112
DATABASE="test"
COLLECTION="test"

WAIT_TIME=60 # in seconds

# docker-compose -f local-compose.yml up -d && \

# echo "--------------------------------------------------" && \
# echo "waiting for $WAIT_TIME seconds..." && \
# sleep $WAIT_TIME && \

echo "--------------------------------------------------" && \
echo "enabling sharding..." && \
docker run -it --rm mongo:3.4 mongo --host "$IP:$MONGOS1_PORT" test --eval "sh.enableSharding('$DATABASE')" && \

echo "--------------------------------------------------" && \
echo "sharding $DATABASE.$COLLECTION" && \
docker run -it --rm mongo:3.4 mongo --host "$IP:$MONGOS1_PORT" test --eval "sh.shardCollection('$DATABASE.$COLLECTION', {'item_id': 'hashed'})" && \

echo "--------------------------------------------------" && \
echo "simulating 10 ingestions from 10 different sources" && \
for i in $(seq 10); do
	echo $i
	docker run --rm mongo:3.4 mongo --host "$IP:$MONGOS1_PORT" test --eval "
		db.$COLLECTION.insertOne(
			{ item_id: $i, count: 1 }
		)
	" &
done && \

echo "--------------------------------------------------" && \
echo "waiting for 5 seconds for ingestion..." && \
sleep 5 && \

echo "--------------------------------------------------" && \
echo "incrementing item_id #5 to count 2"
docker run -it --rm mongo:3.4 mongo --host "$IP:$MONGOS1_PORT" test --eval "
	db.$COLLECTION.update(
		{ item_id: 5 },
		{ \$inc: {count: 1} }
	)
" &&

echo "--------------------------------------------------" && \
echo "check increment"
docker run -it --rm mongo:3.4 mongo --host "$IP:$MONGOS1_PORT" test --eval "
	db.$COLLECTION.find(
		{ number: 5 }
	)
" &&

echo "--------------------------------------------------" && \
docker run -it --rm mongo:3.4 mongo --host "$IP:$MONGOS1_PORT" test --eval "
	db.$COLLECTION.getShardDistribution()
" &&

echo "--------------------------------------------------" && \
echo "done."
