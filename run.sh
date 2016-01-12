#!/bin/bash
VOLUME_CONTAINER_GUID=$(docker ps -a | grep tick-data | egrep -o "[a-z0-9]{12}")
EXISTS=true
TICK_RUNNING=$(docker ps -a | egrep "tick" | egrep -o "[a-z0-9]{12}")

if [ -n "${TICK_RUNNING}" ]; then
  docker rm -f tick
fi

if [ -z "${VOLUME_CONTAINER_GUID}" ]; then
  EXISTS=false
  VOLUME_CONTAINER_GUID=$(
    docker create \
      --name tick-data \
      -v "/data/influx/data" \
      -v "/data/influx/wal" \
      -v "/data/influx/meta" \
      -v "/data/kapacitor" \
      -v "/data/chronograf" \
      mefellows/tick \
      /dev/null
  )
  echo ">> Created persisted data container: ${VOLUME_CONTAINER_GUID}"
fi

docker run \
  -d \
  -p 8086:8086 \
  -p 8125:8125/udp \
  -p 10000:10000 \
  --name tick \
  --volumes-from $VOLUME_CONTAINER_GUID \
  mefellows/tick

HOST=$(docker-machine env dev | grep DOCKER_HOST | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}')
echo ">> Waiting for Influx to be available on active Docker Host (${HOST})"
if command -v nc 2>&1> /dev/null; then
  WAIT=0
  while ! nc -z $HOST 8086; do
    sleep 1
    WAIT=$(($WAIT + 1))
    if [ "$WAIT" -gt 15 ]; then
      echo "Error: Timeout wating for Influx to start"
      exit 1
    fi
  done
else
  echo "NOTE: nc (netcat) not deteced, using arbitrary sleep of 15s"
  sleep 15
fi

if [ $EXISTS != true ]; then
  echo ">> Creating initial telegraf database"
  docker exec -i -t tick curl -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE telegraf"
fi

if [[ $? -eq 0 ]]; then
  echo ""
  echo "You are ready to go, head on over to ${HOST}:10000 and start creating metrics!"
fi
