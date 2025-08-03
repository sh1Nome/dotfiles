#!/bin/sh

# このスクリプトはDocker Composeを起動します
MYUID=$(id -u) MYGID=$(id -g) docker compose down --rmi local -v
