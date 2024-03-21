
cosmos_sdk_wait_for_block_height() {
    if test "$(curl "127.0.0.1:$CONSENSUS_RPC_PORT/block" | jq .result.block.header.height -r)" -lt 5
    then
        sleep 5
    fi
}

cosmos_sdk_upload_wasm() {
     centaurid tx wasm store "$1" --chain-id="$CHAIN_ID" --node="tcp://0.0.0.0:$CONSENSUS_RPC_PORT" --output=json --yes --gas=25000000 --fees="920000166$FEE" --from=APPLICATION2 --trace --log_level=trace

    sleep "$BLOCK_SECONDS"
    
    centaurid query wasm list-code | jq '.code_infos | sort_by(.code_id) | last | .code_id' -r    
}