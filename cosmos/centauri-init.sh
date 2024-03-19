#!/usr/bin/env bash
parser_definition() {
    setup REST help:usage -- "Usage: example.sh [options]... [arguments]..."
    msg -- 'Options:'
    option FRESH -f --fresh on:true -- "takes one optional argument"
}

eval "$(getoptions parser_definition) exit 1"

env


if test "$FRESH" != "false" && test -d "$CHAIN_DATA" 
then
    echo "$CHAIN_DATA"
    rm --force --recursive "$CHAIN_DATA"
else
    echo "No chain data to remove"
fi

if [[ ! -d "$CHAIN_DATA" ]]
then
    mkdir --parents "$CHAIN_DATA"
    mkdir --parents "$CHAIN_DATA/config/gentx"
    mkdir --parents "$KEYRING_TEST"
    echo "$VAL_MNEMONIC_1" | centaurid init "$CHAIN_ID" --chain-id "$CHAIN_ID" --default-denom "$FEE" --home "$CHAIN_DATA"  --recover

    jq-genesis() {
        jq -r  "$1"  > "$CHAIN_DATA/config/genesis-update.json"  < "$CHAIN_DATA/config/genesis.json"
        mv --force "$CHAIN_DATA/config/genesis-update.json" "$CHAIN_DATA/config/genesis.json"
    }

    pica_setup() {
        jq-genesis '.app_state.transmiddleware.token_infos[0].ibc_denom |= "ibc/632DBFDB06584976F1351A66E873BF0F7A19FAA083425FEC9890C90993E5F0A4"'
        jq-genesis ".app_state.transmiddleware.token_infos[0].channel_id |= \"channel-$PICA_CHANNEL_ID\""
        jq-genesis '.app_state.transmiddleware.token_infos[0].native_denom |= "ppica"'
        jq-genesis '.app_state.transmiddleware.token_infos[0].asset_id |= "1"'
    }
    pica_setup

    dasel-genesis() {
        dasel put --type string --file "$CHAIN_DATA/config/genesis.json" --value "$2" "$1"
    }

    register_asset () {
        dasel  put --type json --file "$CHAIN_DATA/config/genesis.json" --value "[{}]" ".app_state.bank.denom_metadata.[$1].denom_units"
        dasel-genesis ".app_state.bank.denom_metadata.[$1].description" "$2"
        dasel-genesis ".app_state.bank.denom_metadata.[$1].denom_units.[0].denom" "$2"
        dasel-genesis ".app_state.bank.denom_metadata.[$1].denom_units.[0].exponent" 0
        dasel-genesis ".app_state.bank.denom_metadata.[$1].base" "$2"
        dasel-genesis ".app_state.bank.denom_metadata.[$1].display" "$2"
        dasel-genesis ".app_state.bank.denom_metadata.[$1].name" "$2"
        dasel-genesis ".app_state.bank.denom_metadata.[$1].symbol" "$2"
    }

    dasel put --type json --file "$CHAIN_DATA/config/genesis.json" --value "[{},{}]" 'app_state.bank.denom_metadata'
    register_asset 0 "ptest"
    register_asset 1 "pdemo"

    dasel put --type=string --write=toml --file "$CHAIN_DATA/config/client.toml" --value "test" "keyring-backend"
    dasel put --type=string --write=toml --file "$CHAIN_DATA/config/client.toml" --value "json" "output"
    dasel put --type=string --write=toml --file="$CHAIN_DATA/config/client.toml" --value "$CHAIN_ID" '.chain-id'
    dasel put --type=string --write=toml --file="$CHAIN_DATA/config/client.toml" --value "sync" '.broadcast-mode'
    sed -i 's/minimum-gas-prices = "0stake"/minimum-gas-prices = "0stake"/' "$CHAIN_DATA/config/client.toml"

    sed -i "s/rpc-max-body-bytes = 1000000/rpc-max-body-bytes = 10000000/" "$CHAIN_DATA/config/app.toml"
    sed -i "s/swagger = false/swagger = true/" "$CHAIN_DATA/config/app.toml"
    dasel put --type string --file "$CHAIN_DATA/config/app.toml" --value "0.0.0.0:$GRPCPORT" '.grpc.address'

    dasel put --type string --file "$CHAIN_DATA/config/config.toml" --value "tcp://0.0.0.0:$CONSENSUS_GRPC_PORT" '.rpc.grpc_laddr'

    sed -i "s/cors_allowed_origins = \[\]/cors_allowed_origins = \[\"\*\"\]/" "$CHAIN_DATA/config/config.toml"
    sed -i "s/max_body_bytes = 1000000/max_body_bytes = 10000000/" "$CHAIN_DATA/config/config.toml"
    sed -i "s/max_header_bytes = 1048576/max_header_bytes = 10485760/" "$CHAIN_DATA/config/config.toml"
    sed -i "s/max_tx_bytes = 1048576/max_tx_bytes = 10485760/" "$CHAIN_DATA/config/config.toml"

    echo "$ALICE" | centaurid keys add ALICE --recover --keyring-backend test --keyring-dir "$KEYRING_TEST" || true
    echo "$BOB" | centaurid keys add BOB --recover --keyring-backend test --keyring-dir "$KEYRING_TEST" || true
    echo "$VAL_MNEMONIC_1" | centaurid keys add "VAL_MNEMONIC_1" --recover --keyring-backend test --keyring-dir "$KEYRING_TEST" || true
    echo "notice oak worry limit wrap speak medal online prefer cluster roof addict wrist behave treat actual wasp year salad speed social layer crew genius" | centaurid keys add test1 --recover --keyring-backend test --keyring-dir "$KEYRING_TEST" || true
    echo "quality vacuum heart guard buzz spike sight swarm shove special gym robust assume sudden deposit grid alcohol choice devote leader tilt noodle tide penalty" | centaurid keys add test2 --recover --keyring-backend test --keyring-dir "$KEYRING_TEST" || true
    echo "$RLY_MNEMONIC_1" | centaurid keys add relayer1 --recover --keyring-backend test --keyring-dir "$KEYRING_TEST" || true
    echo "$RLY_MNEMONIC_2" | centaurid keys add relayer2 --recover --keyring-backend test --keyring-dir "$KEYRING_TEST" || true
    echo "$RLY_MNEMONIC_3" | centaurid keys add relayer3 --recover --keyring-backend test --keyring-dir "$KEYRING_TEST" || true
    echo "$RLY_MNEMONIC_4" | centaurid keys add relayer4 --recover --keyring-backend test --keyring-dir "$KEYRING_TEST" || true
    echo "$APPLICATION1" | centaurid keys add APPLICATION1 --recover --keyring-backend test --keyring-dir "$KEYRING_TEST" || true
    echo "$APPLICATION2" | centaurid keys add APPLICATION2 --recover --keyring-backend test --keyring-dir "$KEYRING_TEST" || true

    add-genesis-account () {
        echo "adding $1"
        centaurid --keyring-backend test add-genesis-account "$1" "10000000000000000000000000000ppica,100000000000000000000000ptest,100000000000000000000000pdemo" --home "$CHAIN_DATA"
    }

    add-genesis-account "$("$BINARY" keys show relayer1 --keyring-backend test --keyring-dir "$KEYRING_TEST" --output json | jq .address -r )"
    add-genesis-account "$("$BINARY" keys show relayer2 --keyring-backend test --keyring-dir "$KEYRING_TEST" --output json | jq .address -r )"
    add-genesis-account "$("$BINARY" keys show relayer3 --keyring-backend test --keyring-dir "$KEYRING_TEST" --output json | jq .address -r )"
    add-genesis-account "$("$BINARY" keys show relayer4 --keyring-backend test --keyring-dir "$KEYRING_TEST" --output json | jq .address -r )"
    add-genesis-account "$("$BINARY" keys show APPLICATION1 --keyring-backend test --keyring-dir "$KEYRING_TEST" --output json | jq .address -r )"
    add-genesis-account "$("$BINARY" keys show APPLICATION2 --keyring-backend test --keyring-dir "$KEYRING_TEST" --output json | jq .address -r )"
    add-genesis-account "$("$BINARY" keys show "VAL_MNEMONIC_1" --keyring-backend test --keyring-dir "$KEYRING_TEST" --output json | jq .address -r )"

    add-genesis-account centauri1zr4ng42laatyh9zx238n20r74spcrlct6jsqaw
    add-genesis-account ASD
    add-genesis-account centauri1cyyzpxplxdzkeea7kwsydadg87357qnamvg3y3
    add-genesis-account centauri18s5lynnmx37hq4wlrw9gdn68sg2uxp5ry85k7d
    centaurid --keyring-backend test --keyring-dir "$KEYRING_TEST" --home "$CHAIN_DATA" gentx "VAL_MNEMONIC_1" "250000000000000ppica" --chain-id="$CHAIN_ID" --amount="250000000000000ppica"
    centaurid collect-gentxs --home "$CHAIN_DATA"  --gentx-dir "$CHAIN_DATA/config/gentx"
else
    echo "WARNING: REUSING EXISTING DATA FOLDER"
fi