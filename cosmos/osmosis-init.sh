#!/usr/bin/env bash
parser_definition() {
    setup REST help:usage -- "Usage: example.sh [options]... [arguments]..."
    msg -- 'Options:'
    option FRESH -f --fresh on:true -- "takes one optional argument"
}

eval "$(getoptions parser_definition) exit 1"


if test "$FRESH" != "false" && test -d "$CHAIN_DATA" 
then
    echo "$CHAIN_DATA"
    rm --force --recursive "$CHAIN_DATA"
else
    echo "No chain data to remove"
fi

if [[ ! -d "$CHAIN_DATA" ]]
then

    mkdir --parents "$CHAIN_DATA/data/cs.wal"

    echo "$VAL_MNEMONIC_1" | osmosisd init --chain-id="$CHAIN_ID" --home "$CHAIN_DATA" --recover "VAL_MNEMONIC_1"

    function dasel-genesis() {
        dasel put --type string --file "$GENESIS" --value "$2" "$1"
    }

    dasel-genesis '.app_state.staking.params.bond_denom' 'uosmo'
    dasel-genesis '.app_state.staking.params.unbonding_time' '960s'
    dasel  put --type json --file "$GENESIS" --value "[{},{},{}]" 'app_state.bank.denom_metadata'

    dasel  put --type json --file "$GENESIS" --value "[{}]" '.app_state.bank.denom_metadata.[0].denom_units'
    dasel-genesis '.app_state.bank.denom_metadata.[0].description' 'Registered denom uion for localosmosis testing'
    dasel-genesis '.app_state.bank.denom_metadata.[0].denom_units.[0].denom' 'uion'
    dasel-genesis '.app_state.bank.denom_metadata.[0].denom_units.[0].exponent' 0
    dasel-genesis '.app_state.bank.denom_metadata.[0].base' 'uion'
    dasel-genesis '.app_state.bank.denom_metadata.[0].display' 'uion'
    dasel-genesis '.app_state.bank.denom_metadata.[0].name' 'uion'
    dasel-genesis '.app_state.bank.denom_metadata.[0].symbol' 'uion'

    dasel  put --type json --file "$GENESIS" --value "[{}]" '.app_state.bank.denom_metadata.[1].denom_units'
    dasel-genesis '.app_state.bank.denom_metadata.[1].description' 'Registered denom uosmo for localosmosis testing'
    dasel-genesis '.app_state.bank.denom_metadata.[1].denom_units.[0].denom' 'uosmo'
    dasel-genesis '.app_state.bank.denom_metadata.[1].denom_units.[0].exponent' 0
    dasel-genesis '.app_state.bank.denom_metadata.[1].base' 'uosmo'
    dasel-genesis '.app_state.bank.denom_metadata.[1].display' 'uosmo'
    dasel-genesis '.app_state.bank.denom_metadata.[1].name' 'uosmo'
    dasel-genesis '.app_state.bank.denom_metadata.[1].symbol' 'uosmo'

    dasel  put --type json --file "$GENESIS" --value "[{}]" '.app_state.bank.denom_metadata.[2].denom_units'
    dasel-genesis '.app_state.bank.denom_metadata.[2].description' 'ibc/3262D378E1636BE287EC355990D229DCEB828F0C60ED5049729575E235C60E8B'
    dasel-genesis '.app_state.bank.denom_metadata.[2].denom_units.[0].denom' 'ibc/3262D378E1636BE287EC355990D229DCEB828F0C60ED5049729575E235C60E8B'
    dasel-genesis '.app_state.bank.denom_metadata.[2].denom_units.[0].exponent' 0
    dasel-genesis '.app_state.bank.denom_metadata.[2].base' 'ibc/3262D378E1636BE287EC355990D229DCEB828F0C60ED5049729575E235C60E8B'
    dasel-genesis '.app_state.bank.denom_metadata.[2].display' 'ibc/3262D378E1636BE287EC355990D229DCEB828F0C60ED5049729575E235C60E8B'
    dasel-genesis '.app_state.bank.denom_metadata.[2].name' 'ibc/3262D378E1636BE287EC355990D229DCEB828F0C60ED5049729575E235C60E8B'
    dasel-genesis '.app_state.bank.denom_metadata.[2].symbol' 'ibc/3262D378E1636BE287EC355990D229DCEB828F0C60ED5049729575E235C60E8B'

    dasel  put --type string --file "$GENESIS" --value "transfer" '.app_state.transfer.port_id'
    dasel  put --type json --file "$GENESIS" --value "[{}]" '.app_state.transfer.denom_traces'
    dasel  put --type string --file "$GENESIS" --value "transfer/channel-0" '.app_state.transfer.denom_traces.[0].path'
    dasel  put --type string --file "$GENESIS" --value "ppica" '.app_state.transfer.denom_traces.[0].base_denom'

    dasel-genesis '.app_state.crisis.constant_fee.denom' 'uosmo'
    dasel-genesis '.app_state.gov.voting_params.voting_period' '30s'
    dasel  put --type json --file "$GENESIS" --value "[{}]" '.app_state.gov.deposit_params.min_deposit'
    dasel-genesis '.app_state.gov.deposit_params.min_deposit.[0].denom' 'uosmo'
    dasel-genesis '.app_state.gov.deposit_params.min_deposit.[0].amount' '1000000000'
    dasel-genesis '.app_state.epochs.epochs.[1].duration' "60s"
    dasel  put --type json --file "$GENESIS" --value "[{},{},{}]" '.app_state.poolincentives.lockable_durations'
    dasel-genesis '.app_state.poolincentives.lockable_durations.[0]' "120s"
    dasel-genesis '.app_state.poolincentives.lockable_durations.[1]' "180s"
    dasel-genesis '.app_state.poolincentives.lockable_durations.[2]' "240s"
    dasel-genesis '.app_state.poolincentives.params.minted_denom' "uosmo"
    dasel  put --type json --file "$GENESIS" --value "[{},{},{},{}]" '.app_state.incentives.lockable_durations'
    dasel-genesis '.app_state.incentives.lockable_durations.[0]' "1s"
    dasel-genesis '.app_state.incentives.lockable_durations.[1]' "120s"
    dasel-genesis '.app_state.incentives.lockable_durations.[2]' "180s"
    dasel-genesis '.app_state.incentives.lockable_durations.[3]' "240s"
    dasel-genesis '.app_state.incentives.params.distr_epoch_identifier' "hour"
    dasel-genesis '.app_state.mint.params.mint_denom' "uosmo"
    dasel-genesis '.app_state.mint.params.epoch_identifier' "day"
    dasel-genesis '.app_state.poolmanager.params.pool_creation_fee.[0].denom' "uosmo"

    dasel  put --type json --file "$GENESIS" --value "[{}]" '.app_state.gamm.params.pool_creation_fee'
    dasel-genesis '.app_state.gamm.params.pool_creation_fee.[0].denom' "uosmo"
    dasel-genesis '.app_state.gamm.params.pool_creation_fee.[0].amount' "10000000"
    dasel-genesis '.app_state.txfees.basedenom' "uosmo"
    dasel-genesis '.app_state.wasm.params.code_upload_access.permission' "Everybody"

    function add-genesis-account() {
        echo "$1" | osmosisd keys add "$2" --recover --keyring-backend test --home "$CHAIN_DATA" --keyring-dir "$KEYRING_TEST"
        ACCOUNT=$(osmosisd keys show --address "$2" --keyring-backend test --home "$CHAIN_DATA" )
        echo "$ACCOUNT"
        osmosisd add-genesis-account "$ACCOUNT" 100000000000000000uosmo,100000000000uion,100000000000stake,10000000000000ibc/3262D378E1636BE287EC355990D229DCEB828F0C60ED5049729575E235C60E8B --home "$CHAIN_DATA"
    }

    add-genesis-account "$VAL_MNEMONIC_1" "VAL_MNEMONIC_1"
    add-genesis-account "$FAUCET_MNEMONIC" "FAUCET_MNEMONIC"
    add-genesis-account "$RLY_MNEMONIC_3" "RLY_MNEMONIC_3"
    add-genesis-account "$RLY_MNEMONIC_4" "RLY_MNEMONIC_4"
    add-genesis-account "$APPLICATION1" "APPLICATION1"

    osmosisd gentx "VAL_MNEMONIC_1" 500000000uosmo --keyring-backend=test --chain-id=$CHAIN_ID --home "$CHAIN_DATA"
    osmosisd collect-gentxs --home "$CHAIN_DATA"
    dasel put --type string --file "$CONFIG_FOLDER/config.toml" --value "" '.p2p.seeds'

    dasel put --type string --file "$CONFIG_FOLDER/config.toml" --value "*" '.rpc.cors_allowed_origins.[]'
    dasel put --type string --file "$CONFIG_FOLDER/config.toml" --value "Accept-Encoding" '.rpc.cors_allowed_headers.[]'
    dasel put --type string --file "$CONFIG_FOLDER/config.toml" --value "DELETE" '.rpc.cors_allowed_methods.[]'
    dasel put --type string --file "$CONFIG_FOLDER/config.toml" --value "OPTIONS" '.rpc.cors_allowed_methods.[]'
    dasel put --type string --file "$CONFIG_FOLDER/config.toml" --value "PATCH" '.rpc.cors_allowed_methods.[]'
    dasel put --type string --file "$CONFIG_FOLDER/config.toml" --value "PUT" '.rpc.cors_allowed_methods.[]'
    dasel put --type bool --file "$CONFIG_FOLDER/app.toml" --value "true" '.api.swagger'
    dasel put --type bool --file "$CONFIG_FOLDER/app.toml" --value "true" '.api.enabled-unsafe-cors'
    dasel put --type bool --file "$CONFIG_FOLDER/app.toml" --value "true" '.grpc-web.enable-unsafe-cors'

    dasel put --type string --file "$CONFIG_FOLDER/client.toml" --value "$CHAIN_ID" '.chain-id'
    dasel put --type string --file "$CONFIG_FOLDER/client.toml" --value "test" '.keyring-backend'
    dasel put --type string --file "$CONFIG_FOLDER/client.toml" --value "json" '.output'

    dasel put --type string --file "$CONFIG_FOLDER/app.toml" --value "0.0.0.0:$GRPCPORT" '.grpc.address'
    dasel put --type string --file "$CONFIG_FOLDER/app.toml" --value "0.0.0.0:$GRPCWEB" '.grpc-web.address'
    dasel put --type string --file "$CONFIG_FOLDER/app.toml" --value "tcp://0.0.0.0:$RESTPORT" '.api.address'

    dasel put --type string --file "$CONFIG_FOLDER/config.toml" --value ":$PROMETHEUS_PORT" '.instrumentation.prometheus_listen_addr'
    dasel put --type string --file "$CONFIG_FOLDER/config.toml" --value "0.0.0.0:16060" '.rpc.pprof_laddr'
    dasel put --type string --file "$CONFIG_FOLDER/config.toml" --value "tcp://0.0.0.0:$P2PPORT" '.p2p.laddr'
    dasel put --type string --file "$CONFIG_FOLDER/config.toml" --value "tcp://0.0.0.0:$CONSENSUS_RPC_PORT" '.rpc.laddr'
    dasel put --type string --file "$CONFIG_FOLDER/config.toml" --value "tcp://127.0.0.1:36658" '.proxy_app'

    dasel put --type string --file "$CONFIG_FOLDER/client.toml" --value "tcp://localhost:$CONSENSUS_RPC_PORT" '.node'
fi