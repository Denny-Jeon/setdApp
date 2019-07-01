#!/bin/bash

./cert.sh generate
./cert.sh generate -o org2

./charti.sh generate

./network.sh start

./network.sh startsbn

./network.sh extendsbn