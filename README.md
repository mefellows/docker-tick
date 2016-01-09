# TICK Stack

Simple Docker setup for the [TICK](https://influxdata.com/time-series-platform/) stack.

## Getting Started

```
./build.sh
docker run --name tick -it -p 8086:8086 -p 8125:8125 -p 10000:10000 -d mefellows/tick
docker exec -i -t tick curl -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE telegraf"
docker exec -i -t tick bash # now you can do stuff
```

## Sending and Viewing Metrics

On Mac OSX, using `netcat`:

```
echo "somemetric:1000|c" | nc -c -u docker 8125
```

Visit http://docker:10000 to view your sweet sweet metrics.
