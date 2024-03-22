parser_definition() {
    setup REST help:usage -- "Usage: example.sh [options]... [arguments]..."
    msg -- 'Options:'
}
eval "$(getoptions parser_definition) exit 1"

osmosisd tx gamm create-pool --pool-file="$POOL_CONFIG" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas=25000000 --fees=920000166"$FEE" --keyring-backend=test  --from=APPLICATION1 --trace --log_level=trace --broadcast-mode=sync
sleep "$BLOCK_SECONDS"
osmosisd query gamm pools --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json