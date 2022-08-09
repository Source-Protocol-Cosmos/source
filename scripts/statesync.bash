#!/bin/bash
# microtick and bitcanna contributed significantly here.
# Pebbledb state sync script.
set -uxe

# Set Golang environment variables.
export GOPATH=~/go
export PATH=$PATH:~/go/bin

# Install Source with pebbledb 
go mod edit -replace github.com/tendermint/tm-db=github.com/notional-labs/tm-db@136c7b6
go mod tidy
go install -ldflags '-w -s -X github.com/cosmos/cosmos-sdk/types.DBBackend=pebbledb' -tags pebbledb ./...

# NOTE: ABOVE YOU CAN USE ALTERNATIVE DATABASES, HERE ARE THE EXACT COMMANDS
# go install -ldflags '-w -s -X github.com/cosmos/cosmos-sdk/types.DBBackend=rocksdb' -tags rocksdb ./...
# go install -ldflags '-w -s -X github.com/cosmos/cosmos-sdk/types.DBBackend=badgerdb' -tags badgerdb ./...
# go install -ldflags '-w -s -X github.com/cosmos/cosmos-sdk/types.DBBackend=boltdb' -tags boltdb ./...

# Initialize chain.
sourced init test

# Get Genesis
wget https://download.dimi.sh/source-phoenix2-genesis.tar.gz
tar -xvf source-phoenix2-genesis.tar.gz
mv source-phoenix2-genesis.json "$HOME/.source/config/genesis.json"




# Get "trust_hash" and "trust_height".
INTERVAL=1000
LATEST_HEIGHT="$(curl -s https://source-rpc.polkachu.com/block | jq -r .result.block.header.height)"
BLOCK_HEIGHT="$((LATEST_HEIGHT-INTERVAL))"
TRUST_HASH="$(curl -s "https://source-rpc.polkachu.com/block?height=$BLOCK_HEIGHT" | jq -r .result.block_id.hash)"

# Print out block and transaction hash from which to sync state.
echo "trust_height: $BLOCK_HEIGHT"
echo "trust_hash: $TRUST_HASH"

# Export state sync variables.
export SOURCED_STATESYNC_ENABLE=true
export SOURCED_P2P_MAX_NUM_OUTBOUND_PEERS=200
export SOURCED_STATESYNC_RPC_SERVERS="https://rpc-source-ia.notional.ventures:443,https://source-rpc.polkachu.com:443"
export SOURCED_STATESYNC_TRUST_HEIGHT=$BLOCK_HEIGHT
export SOURCED_STATESYNC_TRUST_HASH=$TRUST_HASH

# Fetch and set list of seeds from chain registry.
SOURCED_P2P_SEEDS="$(curl -s https://raw.githubusercontent.com/cosmos/chain-registry/master/source/chain.json | jq -r '[foreach .peers.seeds[] as $item (""; "\($item.id)@\($item.address)")] | join(",")')"
export SOURCED_P2P_SEEDS

# Start chain.
sourced start --x-crisis-skip-assert-invariants --db_backend pebbledb
