
cosmos_sdk_wait_for_block_height() {
    if test "$(curl --silent --show-error "127.0.0.1:$CONSENSUS_RPC_PORT/block" | jq .result.block.header.height -r)" -lt 5
    then
        sleep 2
    fi
}

cosmos_sdk_show_key() {
    centaurid keys show "$1" --keyring-backend test  | jq .address -r
}

cosmos_sdk_height() {
    curl --silent --show-error "0.0.0.0:$CONSENSUS_RPC_PORT/block" | jq .result.block.header.height -r
}

cosmos_sdk_next() {
    local -r HEIGHT=$(curl --silent --show-error "0.0.0.0:$CONSENSUS_RPC_PORT/block" | jq .result.block.header.height -r)
    # shellcheck disable=SC2046
    while test $(curl --silent --show-error "0.0.0.0:$CONSENSUS_RPC_PORT/block" | jq .result.block.header.height -r) -le "$HEIGHT"
    do
        sleep 1
    done
}

cosmos_sdk_upload_wasm() {
     centaurid tx wasm store "$1" --chain-id="$CHAIN_ID" --node="tcp://0.0.0.0:$CONSENSUS_RPC_PORT" --output=json --yes --gas=25000000 --fees="920000166$FEE" --from=APPLICATION2 --trace --log_level=trace
    cosmos_sdk_next
    centaurid query wasm list-code | jq '.code_infos | sort_by(.code_id | tonumber) | last | .code_id' -r    
}
