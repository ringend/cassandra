#!/bin/bash
#

#############################
# Start first node
docker run  \
--name cass-node-1 \
-p 9042:9042 \
-e CASSANDRA_CLUSTER_NAME="cassendra-cluster-1"  \
-e CASSANDRA_NUM_TOKENS="8" \
-e CASSANDRA_DC="atldc1" \
-e CASSANDRA_RACK="rack1" \
-e CASSANDRA_ENDPOINT_SNITCH="GossipingPropertyFileSnitch" \
-v /home/docker-data/cassandra/node-1:/var/lib/cassandra \
-d cassandra:latest

INSTANCE1=$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" cassandra-1)
echo "Instance 1: ${INSTANCE1}"

echo "Wait 120s for node to come online"
sleep 120
docker exec cass-node-1 nodetool status

##############################
# Run the second node -note different port
docker run  \
--name cass-node-2 \
-p 9043:9042 \
-e CASSANDRA_CLUSTER_NAME="cassendra-cluster-1"  \
-e CASSANDRA_NUM_TOKENS="8" \
-e CASSANDRA_DC="atldc1" \
-e CASSANDRA_RACK="rack2" \
-e CASSANDRA_ENDPOINT_SNITCH="GossipingPropertyFileSnitch" \
-v /home/docker-data/cassandra/node-2:/var/lib/cassandra \
-e CASSANDRA_SEEDS=$INSTANCE1 \
-d cassandra:latest

sleep 10
$INSTANCE2=$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" cassandra-2)
echo "Instance 2: ${INSTANCE2}"

echo "Wait 240s until the second node joins the cluster"
sleep 240
docker exec cass-node-2 nodetool status

#############################
# Run the third node
docker run \
--name cass-node-3 \
-p 9044:9042 \
-e CASSANDRA_CLUSTER_NAME="cassendra-cluster-1"  \
-e CASSANDRA_NUM_TOKENS="8" \
-e CASSANDRA_DC="atldc1" \
-e CASSANDRA_RACK="rack3" \
-e CASSANDRA_ENDPOINT_SNITCH="GossipingPropertyFileSnitch" \
-v /home/docker-data/cassandra/node-3:/var/lib/cassandra \
-e CASSANDRA_SEEDS=$INSTANCE1 \
-d cassandra:latest

#-d -e CASSANDRA_SEEDS=$INSTANCE1,$INSTANCE2 cassandra:latest

#sleep 10
#$INSTANCE3=$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" cassandra-3)

echo "Wait 180s until the second node joins the cluster"
sleep 180
docker exec cass-node-3 nodetool status

