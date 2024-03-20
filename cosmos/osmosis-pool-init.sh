"$BINARY" tx gamm create-pool --pool-file=${./osmosis-gamm-pool-pica-osmo.json} --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas=25000000 --fees=920000166"$FEE" --keyring-backend=test  --home="$CHAIN_DATA" --from=pools --keyring-dir="$KEYRING_TEST" ${log} --broadcast-mode=sync
sleep "$BLOCK_SECONDS"
"$BINARY" query gamm pools --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --home="$CHAIN_DATA"