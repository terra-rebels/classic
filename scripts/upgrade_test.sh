#!/bin/bash

OLD_BRANCH=main
NEW_BRANCH=ibc-3.4.0-bump
UPGRADE_HEIGHT=30
HOME=mytestnet

# install old binary
if ! command -v build/old/terrad &> /dev/null
then
    git checkout $OLD_BRANCH

    go build -mod=readonly -o build/old/terrad ./cmd/terrad
fi


# install new binary
if ! command -v build/new/terrad &> /dev/null
then
    git checkout $NEW_BRANCH

    go build -mod=readonly -o build/new/terrad ./cmd/terrad
fi

# start old node
screen -S node1 -d -m bash scripts/start-node.sh build/old/terrad

sleep 15

./build/old/terrad tx gov submit-proposal software-upgrade v2 --upgrade-height $UPGRADE_HEIGHT --upgrade-info "temp" --title "upgrade" --description "upgrade"  --from test1 --keyring-backend test --chain-id test --home mytestnet -y

sleep 3

./build/old/terrad tx gov deposit 1 20000000uluna --from test1 --keyring-backend test --chain-id test --home mytestnet -y

sleep 3

./build/old/terrad tx gov vote 1 yes --from test --keyring-backend test --chain-id test --home mytestnet -y

sleep 3

./build/old/terrad tx gov vote 1 yes --from test1 --keyring-backend test --chain-id test --home mytestnet -y

sleep 3

# determine block_height to halt
while true; do 
    BLOCK_HEIGHT=$(./build/new/terrad status | jq '.SyncInfo.latest_block_height' -r)
    if [ $BLOCK_HEIGHT = "$UPGRADE_HEIGHT" ]; then
        # assuming running only 1 terrad
        echo "BLOCK HEIGHT = $UPGRADE_HEIGHT REACHED, KILLING OLD ONE"
        pkill terrad
        break
    else
        ./build/old/terrad q gov proposal 1 --output=json | jq ".status"
        echo "BLOCK_HEIGHT = $BLOCK_HEIGHT"
        sleep 10
    fi
done

sleep 3

./build/new/terrad start --home $HOME