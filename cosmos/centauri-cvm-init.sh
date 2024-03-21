#!/usr/bin/env bash

cosmos_sdk_wait_for_block_height

THE_BLOCK=$(cosmos_sdk_height)
echo "$THE_BLOCK"
THE_BLOCK_HASH=$(echo "$THE_BLOCK" | xxd -p -u)

CW_CVM_OUTPOST_CODE_ID=$(cosmos_sdk_upload_wasm "$CW_CVM_OUTPOST_WASM" | tail --lines 1)
echo "$CW_CVM_OUTPOST_CODE_ID"

CW_CVM_EXECUTOR_CODE_ID=$(cosmos_sdk_upload_wasm "$CW_CVM_EXECUTOR_WASM" | tail --lines 1)
echo "$CW_CVM_EXECUTOR_CODE_ID"

CW_MANTIS_ORDER_CODE_ID=$(cosmos_sdk_upload_wasm "$CW_MANTIS_ORDER_WASM" | tail --lines 1)
echo "$CW_MANTIS_ORDER_CODE_ID"


APPLICATION2_ADDRESS=$(cosmos_sdk_show_key APPLICATION2)

INSTANTIATE=$(cat << EOF
    {
        "admin" : "$APPLICATION2_ADDRESS",
        "network_id" : $NETWORK_ID
    }
EOF
)

"$BINARY" tx wasm instantiate2 "$CW_CVM_OUTPOST_CODE_ID" "$INSTANTIATE" "$THE_BLOCK_HASH" --label "composable_cvm_outpost_$THE_BLOCK" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas=25000000 --fees=920000166$FEE  --from="APPLICATION2" --admin="$APPLICATION2_ADDRESS" --amount=1000000000000$FEE

cosmos_sdk_next

CVM_OUTPOST_CONTRACT_ADDRESS=$("$BINARY" query wasm list-contract-by-code "$CW_CVM_OUTPOST_CODE_ID" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output=json | dasel --read json '.contracts.[0]' --write=yaml)

echo "$CVM_OUTPOST_CONTRACT_ADDRESS" > "$CHAIN_DATA/CVM_OUTPOST_CONTRACT_ADDRESS"

"$BINARY" tx wasm instantiate2 "$CW_MANTIS_ORDER_CODE_ID" "{\"cvm_address\": \"$CVM_OUTPOST_CONTRACT_ADDRESS\"}" "$THE_BLOCK_HASH" --label "composable_mantis_order_$THE_BLOCK" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas=25000000 --fees=920000166$FEE  --from="APPLICATION2" --admin="$APPLICATION2_ADDRESS" --amount=1000000000000$FEE

cosmos_sdk_next

MANTIS_ORDER_CONTRACT_ADDRESS=$("$BINARY" query wasm list-contract-by-code "$CW_MANTIS_ORDER_CODE_ID" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output=json | dasel --read json '.contracts.[0]' --write=yaml)

echo "$MANTIS_ORDER_CONTRACT_ADDRESS" > "$CHAIN_DATA/MANTIS_ORDER_CONTRACT_ADDRESS"