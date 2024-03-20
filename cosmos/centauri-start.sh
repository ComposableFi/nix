parser_definition() {
    setup REST help:usage -- "Usage: example.sh [options]... [arguments]..."
    msg -- 'Options:'
    option FRESH -f --fresh on:true -- "takes one optional argument"
    option PICA_CHANNEL_ID -p --pica-channel-id on:1 -- "takes one optional argument"
}

eval "$(getoptions parser_definition) exit 1"

mkdir --parents $LOG_DIRECTORY

centaurid start --rpc.unsafe --rpc.laddr tcp://0.0.0.0:$CONSENSUS_RPC_PORT --pruning=nothing --minimum-gas-prices=0.001$FEE --home="$CHAIN_DATA" --db_dir="$CHAIN_DATA/data" --log_level trace --trace --with-tendermint=true --transport=socket --trace-store=$LOG_DIRECTORY/kvstore.log --grpc.address=0.0.0.0:$GRPCPORT --grpc.enable=true --grpc-web.enable=false --api.enable=true --cpu-profile=$LOG_DIRECTORY/cpu-profile.log --p2p.pex=false --p2p.upnp=false
