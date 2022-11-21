#!/bin/bash

OLD_VERSION=1.0.4
UPGRADE_HEIGHT=30
HOME=mytestnet
ROOT=$(pwd)

# install old binary
if ! command -v build/old/terrad &> /dev/null
then
    mkdir -p build/old
    wget -c "https://github.com/terra-rebels/classic/archive/refs/tags/v${OLD_VERSION}.zip" -O build/v${OLD_VERSION}.zip
    unzip build/v${OLD_VERSION}.zip -d build
    cd ./build/classic-${OLD_VERSION}
    GOBIN="$ROOT/build/old" go install -mod=readonly ./... 2 > dev/null
fi

# install new binary
if ! command -v build/new/terrad &> /dev/null
then
    GOBIN="$ROOT/build/new" go install -mod=readonly ./... 2 > dev/null
fi

# start old node
screen -S node1 -d -Lm bash scripts/start-node.sh build/old/terrad

sleep 20

./build/old/terrad tx gov submit-proposal software-upgrade v2 --upgrade-height $UPGRADE_HEIGHT --upgrade-info "temp" --title "upgrade" --description "upgrade"  --from test1 --keyring-backend test --chain-id test --home $HOME -y

sleep 3

./build/old/terrad tx gov deposit 1 20000000uluna --from test1 --keyring-backend test --chain-id test --home $HOME -y

sleep 3

./build/old/terrad tx gov vote 1 yes --from test --keyring-backend test --chain-id test --home $HOME -y

sleep 3

./build/old/terrad tx gov vote 1 yes --from test1 --keyring-backend test --chain-id test --home $HOME -y

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