#!/usr/bin/env bash

cosmos_sdk_wait_for_block_height

CW_CVM_OUTPOST_CODE_ID=$(cosmos_sdk_upload_wasm "$CW_CVM_OUTPOST_WASM")
echo "$CW_CVM_OUTPOST_CODE_ID"

GATEWAY_CODE_ID=$(cosmos_sdk_upload_wasm "$CW_CVM_EXECUTOR_WASM")
echo "$GATEWAY_CODE_ID"


# init_cvm() {
#     local CVM_INSTANTIATE=$1

#     # GATEWAY_CODE_ID=1

#     # "$BINARY" tx wasm store  "${
#     # self.inputs.cvm.packages."${system}".cw-cvm-executor
#     # }/lib/cw_cvm_executor.wasm" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --yes --gas 25000000 --fees 920000166$FEE ${log} --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST"
#     # EXECUTOR_CODE_ID=2
#     # sleep $BLOCK_SECONDS
#     # "$BINARY" tx wasm store  ${
#     # self.inputs.cosmos.packages.${system}.cw20-basegit 
#     # }/lib/cw20_base.wasm --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --yes --gas 25000000 --fees 920000166$FEE ${log} --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST"

#     # sleep $BLOCK_SECONDS
#     # "$BINARY" tx wasm store  "${
#     # self.inputs.cvm.packages."${system}".cw-mantis-order
#     # }/lib/cw_mantis_order.wasm" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --yes --gas 25000000 --fees 920000166$FEE ${log} --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST"
#     # ORDER_CODE_ID=4

#     # sleep $BLOCK_SECONDS
#     # "$BINARY" tx wasm instantiate2 $GATEWAY_CODE_ID "$INSTANTIATE" "2121" --label "composable_cvm_outpost" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --yes --gas 25000000 --fees 920000166$FEE ${log} --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST" --admin "$KEY" --amount 1000000000000$FEE

#     # sleep $BLOCK_SECONDS
#     # OUTPOST_CONTRACT_ADDRESS=$("$BINARY" query wasm list-contract-by-code "$GATEWAY_CODE_ID" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --home "$CHAIN_DATA" | dasel --read json '.contracts.[0]' --write yaml)
#     # echo "$OUTPOST_CONTRACT_ADDRESS" > "$CHAIN_DATA/outpost_contract_address"

#     # sleep $BLOCK_SECONDS
#     # echo "{\"cvm_address\": \"$OUTPOST_CONTRACT_ADDRESS\"}"
#     # "$BINARY" tx wasm instantiate2 $ORDER_CODE_ID "{\"cvm_address\": \"$OUTPOST_CONTRACT_ADDRESS\"}" "2121" --label "composable_mantis_order" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --yes --gas 25000000 --fees 920000166$FEE ${log} --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST" --admin "$KEY" --amount 1000000000000$FEE


#     # echo "wait for next block"
#     # sleep $BLOCK_SECONDS
#     # ORDER_CONTRACT_ADDRESS=$("$BINARY" query wasm list-contract-by-code "$ORDER_CODE_ID" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --home "$CHAIN_DATA" | dasel --read json '.contracts.[0]' --write yaml)
#     # echo "$ORDER_CONTRACT_ADDRESS" > "$CHAIN_DATA/ORDER_CONTRACT_ADDRESS"

#     # echo "$EXECUTOR_CODE_ID" > "$CHAIN_DATA/executor_code_id"
# }

# INSTANTIATE=$(cat << EOF
#     {
#         "admin" : "$APPLICATION2_ADDRESS",
#         "network_id" : $NETWORK_ID
#     }
# EOF
# )

# init_cvm "$INSTANTIATE"
