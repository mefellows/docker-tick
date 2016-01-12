#!/bin/bash -e

docker build -t mefellows/tick .
docker push mefellows/tick
