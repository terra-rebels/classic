#!/bin/sh

rm -rf mytestnet

BINARY=$1
HOME=mytestnet
CHAIN_ID="test"
KEYRING="test"
KEY="test"
KEY1="test1"

$BINARY init --chain-id $CHAIN_ID moniker --home $HOME

$BINARY keys add $KEY --keyring-backend $KEYRING --home $HOME

$BINARY keys add $KEY1 --keyring-backend $KEYRING --home $HOME

# Allocate genesis accounts (cosmos formatted addresses)
$BINARY add-genesis-account $KEY 1000000000000uluna --keyring-backend $KEYRING --home $HOME

$BINARY add-genesis-account $KEY1 1000000000000uluna --keyring-backend $KEYRING --home $HOME

cat $HOME/config/genesis.json | jq '.app_state["gov"]["voting_params"]["voting_period"] = "50s"' > $HOME/config/tmp_genesis.json && mv $HOME/config/tmp_genesis.json $HOME/config/genesis.json

# Sign genesis transaction
$BINARY gentx $KEY 1000000uluna --keyring-backend $KEYRING --chain-id $CHAIN_ID --home $HOME

# Collect genesis tx
$BINARY collect-gentxs --home $HOME

# Run this to ensure everything worked and that the genesis file is setup correctly
$BINARY validate-genesis --home $HOME

$BINARY start --home $HOME