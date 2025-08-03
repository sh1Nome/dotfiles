#!/bin/sh

# このスクリプトはDocker Composeを起動します
MYUID=$(id -u) MYGID=$(id -g) docker compose up -d --build
