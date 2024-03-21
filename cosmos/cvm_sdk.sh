

# force writes changes to CVM config on specified chain
cvm_sdk_force_config() {
    local -r FORCE_CONFIG=$(cat "$FORCE_CONFIG_FILE") 
           
    "$BINARY" tx wasm execute "$CW_OUTPOST_CONTRACT_ADDRESS" "$FORCE_CONFIG" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas=25000000 --fees=920000166"$FEE" --from="$PAYER_ADDRESS" 

    cosmos_sdk_next

    "$BINARY" query wasm contract-state all "$CW_OUTPOST_CONTRACT_ADDRESS" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json | jq .    
}