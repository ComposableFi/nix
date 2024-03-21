
cosmos_sdk_current_chain(){
   BINARY=${BINARY:="centaurid"}
   echo  "given what binary in path, what chain id and binary env var and what home is, tries to guess the current chain"
}

# waits for minimal block length
cosmos_sdk_wait_for_block_height() {
    if test "$(curl --silent --show-error "127.0.0.1:$CONSENSUS_RPC_PORT/block" | jq .result.block.header.height -r)" -lt 5
    then
        sleep 2
    fi
}

# shows key for moniker
cosmos_sdk_show_key() {
    $BINARY keys show "$1" --keyring-backend test  | jq .address -r
}

# returns the current block height
cosmos_sdk_height() {
    curl --silent --show-error "0.0.0.0:$CONSENSUS_RPC_PORT/block" | jq .result.block.header.height -r
}

# waitss for next block from now
cosmos_sdk_next() {
    local -r HEIGHT=$(curl --silent --show-error "0.0.0.0:$CONSENSUS_RPC_PORT/block" | jq .result.block.header.height -r)
    # shellcheck disable=SC2046
    while test $(curl --silent --show-error "0.0.0.0:$CONSENSUS_RPC_PORT/block" | jq .result.block.header.height -r) -le "$HEIGHT"
    do
        sleep 1
    done
}

# upload wasm file and return code id
cosmos_sdk_upload_wasm() {
     $BINARY tx wasm store "$1" --chain-id="$CHAIN_ID" --node="tcp://0.0.0.0:$CONSENSUS_RPC_PORT" --output=json --yes --gas=25000000 --fees="920000166$FEE" --from=APPLICATION2 --trace --log_level=trace
    cosmos_sdk_next
    $BINARY query wasm list-code | jq '.code_infos | sort_by(.code_id | tonumber) | last | .code_id' -r    
}
