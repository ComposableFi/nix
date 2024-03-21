#!/usr/bin/env sh
cosmos_sdk_wait_for_block_height() {
    if test "$(curl "127.0.0.1:$CONSENSUS_RPC_PORT/block" | jq .result.block.header.height -r)" -lt 5
    then
        sleep 5
    fi
}