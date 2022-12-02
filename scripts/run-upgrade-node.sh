#!/bin/bash

rm -rf mytestnet

BINARY=$1
DENOM=$2
HOME=mytestnet
CHAIN_ID="test"
KEYRING="test"
KEY="test"
KEY1="test1"

# Function updates the config based on a jq argument as a string
update_test_genesis () {
    # EX: update_test_genesis '.consensus_params["block"]["max_gas"]="100000000"'
    cat $HOME/config/genesis.json | jq --arg DENOM "$2" "$1" > $HOME/config/tmp_genesis.json && mv $HOME/config/tmp_genesis.json $HOME/config/genesis.json
}

$BINARY init --chain-id $CHAIN_ID moniker --home $HOME

$BINARY keys add $KEY --keyring-backend $KEYRING --home $HOME

$BINARY keys add $KEY1 --keyring-backend $KEYRING --home $HOME

# Allocate genesis accounts (cosmos formatted addresses)
$BINARY add-genesis-account $KEY "1000000000000${DENOM}" --keyring-backend $KEYRING --home $HOME

$BINARY add-genesis-account $KEY1 "1000000000000${DENOM}" --keyring-backend $KEYRING --home $HOME

update_test_genesis '.app_state["gov"]["voting_params"]["voting_period"] = "50s"'
update_test_genesis '.app_state["mint"]["params"]["mint_denom"]=$DENOM' $DENOM
update_test_genesis '.app_state["gov"]["deposit_params"]["min_deposit"]=[{"denom": $DENOM,"amount": "1000000"}]' $DENOM
update_test_genesis '.app_state["crisis"]["constant_fee"]={"denom": $DENOM,"amount": "1000"}' $DENOM
update_test_genesis '.app_state["staking"]["params"]["bond_denom"]=$DENOM' $DENOM

# Sign genesis transaction
$BINARY gentx $KEY "1000000${DENOM}" --keyring-backend $KEYRING --chain-id $CHAIN_ID --home $HOME

# Collect genesis tx
$BINARY collect-gentxs --home $HOME

# Run this to ensure everything worked and that the genesis file is setup correctly
$BINARY validate-genesis --home $HOME

$BINARY start --home $HOME