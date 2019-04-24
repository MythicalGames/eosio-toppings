#!/usr/bin/env bash
set -o errexit

CONTRACTFILE=$(basename -- "$1")
EXTENSION="${CONTRACTFILE##*.}"
CONTRACTNAME="${CONTRACTFILE%.*}"
FULLFILEPATH=$1

# sourcing variable from config file
source ./config.file

# override config if there are any local config changes
if [ -f "./config.file.local" ]; then
  source ./config.file.local
fi

# Verify everything is clean and setup properly
echo "[Quick Start Engage] First time setup..."
sh ./build_eosio_cdt_docker.sh

# Checks if the Docker container is already running. If it is, then compile the contract as normal.
if [ "$(docker ps -q -f name=$CDT_CONTAINER_NAME)" ]; then
    if [ "$(docker ps -aq -f status=running -f name=$CDT_CONTAINER_NAME)" ]; then
        echo "$CDT_CONTAINER_NAME docker is already running"
    fi
fi

# If the Docker container is not running, then spin it up and compile.
# We can leave it running and destroy it later on.
if [ ! "$(docker ps -q -f name=$CDT_CONTAINER_NAME)" ]; then
    if [ "$(docker ps -aq -f status=exited -f name=$CDT_CONTAINER_NAME)" ]; then
        # Guard against exited container that somehow still exists in docker ps listing.
        # Cleanup.
        docker rm -fv $CDT_CONTAINER_NAME
    fi
    echo "cleaning compiled_contracts cache"
    # clean out the previous compiled contracts
    rm -rf compiled_contracts
    mkdir compiled_contracts

    sh ./start_eosio_cdt_docker.sh

    echo "starting compilation of smart contract"
    shift 1
    echo "$@"
    docker exec -i $CDT_CONTAINER_NAME ./scripts/compile_contract.sh "$FULLFILEPATH" "$@" \
        > stdout.txt 2> stderr.txt \
        && echo "exec pass" || echo "exec fail"

    echo "check log.txt for piped file"

    echo "copying compiled smart contract"
    docker cp $CDT_CONTAINER_NAME:/opt/eosio/bin/compiled_contracts/$CONTRACTNAME "$(pwd)"/compiled_contracts
    echo "copying compiled smart contract finished"
fi
