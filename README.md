# TICK Stack

Simple Docker setup for the [TICK](https://influxdata.com/time-series-platform/) (Telegraf, InfluxDB, Chronograf and Kapacitor) stack.

*NOTE*: This is not an recommended for a highly available and performant Production stack.

## Getting Started

The simplest way forward is to run the following scripts:

```
./build.sh
./run.sh
```

This will build the image and then run a simple configuration that will work nicely for local development or a test server.

### Detail

On MacOSX / Windows, we essentially create a [data volume container](https://docs.docker.com/engine/userguide/dockervolumes/#creating-and-mounting-a-data-volume-container) and then mount that volume from the TICK container as follows:

```
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

docker run \
  -d \
  -p 8086:8086 \
  -p 8125:8125/udp \
  -p 10000:10000 \
  --name tick \
  --volumes-from $VOLUME_CONTAINER_GUID \
  mefellows/tick
docker exec -i -t tick curl -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE telegraf"
docker exec -i -t tick bash # now you can do stuff
````

*NOTE*: due to file system [requirements](https://github.com/influxdata/influxdb/issues/4425), mounting volumes as per [below](#running-in-production) only works on environments with native Docker.

## Sending and Viewing Metrics

On Mac OSX, using `netcat`:

```
echo "somemetric:1000|c" | nc -c -u docker 8125
```

Visit [http://docker:10000](http://docker:10000) to view your sweet sweet metrics.

## Running in Production

```
docker run \
  --name tick \
  -d \
  -p 8086:8086 -p 8125:8125/udp -p 10000:10000 \
  -v "$PWD/.influxdb/data:/data/influx/data" \
  -v "$PWD/.influxdb/wal:/data/influx/wal" \
  -v "$PWD/.influxdb/meta:/data/influx/meta" \
  -v "$PWD/.influxdb/kapacitor:/data/kapacitor" \
  -v "$PWD/.influxdb/chronograf:/data/chronograf" \
  mefellows/tick
```

Mount `/data/influx/data`,  `/data/influx/meta`,  `/data/influx/wal`, `/data/chronograf` and `/data/kapacitor` to (ideally separate - particularly the `data` and `wal` ones) persisted volumes (e.g. EBS volumes).
