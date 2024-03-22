parser_definition() {
    setup REST help:usage -- "Usage: example.sh [options]... [arguments]..."
    msg -- 'Options:'
}
eval "$(getoptions parser_definition) exit 1"

mkdir --parents "$LOG_DIRECTORY"

centaurid start --rpc.unsafe --rpc.laddr="tcp://0.0.0.0:$CONSENSUS_RPC_PORT" --pruning=nothing --minimum-gas-prices="0.001$FEE" --db_dir="$CHAIN_DATA/data" --log_level trace --trace --with-tendermint=true --transport=socket --trace-store="$LOG_DIRECTORY/kvstore.log" --grpc.address=0.0.0.0:$GRPCPORT --grpc.enable=true --grpc-web.enable=false --api.enable=true --cpu-profile="$LOG_DIRECTORY/cpu-profile.log" --p2p.pex=false --p2p.upnp=false
