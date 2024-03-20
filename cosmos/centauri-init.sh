#!/usr/bin/env bash
parser_definition() {
    setup REST help:usage -- "Usage: example.sh [options]... [arguments]..."
    msg -- 'Options:'
    option FRESH -f --fresh on:true -- "takes one optional argument"
    option PICA_CHANNEL_ID -p --pica-channel-id on:1 -- "takes one optional argument"
}

eval "$(getoptions parser_definition) exit 1"

PICA_CHANNEL_ID="''${PICA_CHANNEL_ID:=1}"

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


    add_key () {
        echo "$1" | centaurid keys add "$2" --recover --keyring-backend test   >> /dev/null 2>&1        
        centaurid keys show "$2" --keyring-backend test  | jq .address -r
    }
    
    add-genesis-account () {
        echo "adding $1"
        centaurid --keyring-backend test add-genesis-account "$1" "10000000000000000000000000000ppica,100000000000000000000000ptest,100000000000000000000000pdemo" --home "$CHAIN_DATA" 
    }    

    ALICE_ADDRESS=$(add_key "$ALICE" "ALICE")
    add-genesis-account "$ALICE_ADDRESS"
    
    BOB_ADDRESS=$(add_key "$BOB" "BOB")
    add-genesis-account "$BOB_ADDRESS"
    
    VAL_MNEMONIC_1_ADDRESS=$(add_key "$VAL_MNEMONIC_1" "VAL_MNEMONIC_1")
    add-genesis-account "$VAL_MNEMONIC_1_ADDRESS"
    
    RLY_MNEMONIC_1_ADDRESS=$(add_key "$RLY_MNEMONIC_1" "RLY_MNEMONIC_1")
    add-genesis-account "$RLY_MNEMONIC_1_ADDRESS"
    
    RLY_MNEMONIC_2_ADDRESS=$(add_key "$RLY_MNEMONIC_2" "RLY_MNEMONIC_2")
    add-genesis-account "$RLY_MNEMONIC_2_ADDRESS"
    
    RLY_MNEMONIC_3_ADDRESS=$(add_key "$RLY_MNEMONIC_3" "RLY_MNEMONIC_3")
    add-genesis-account "$RLY_MNEMONIC_3_ADDRESS"
    
    RLY_MNEMONIC_4_ADDRESS=$(add_key "$RLY_MNEMONIC_4" "RLY_MNEMONIC_4")
    add-genesis-account "$RLY_MNEMONIC_4_ADDRESS"
    
    APPLICATION1_ADDRESS=$(add_key "$APPLICATION1" "APPLICATION1")
    add-genesis-account "$APPLICATION1_ADDRESS"
    
    APPLICATION2_ADDRESS=$(add_key "$APPLICATION2" "APPLICATION2")
    add-genesis-account "$APPLICATION2_ADDRESS"
    
    TEST1_ADDRESS=$(add_key "$TEST1" "TEST1")
    add-genesis-account "$TEST1_ADDRESS"
    
    TEST2_ADDRESS=$(add_key "$TEST2" "TEST2")
    add-genesis-account "$TEST2_ADDRESS"
        

    centaurid --keyring-backend test  --home "$CHAIN_DATA" gentx "VAL_MNEMONIC_1" "250000000000000ppica" --chain-id="$CHAIN_ID" --amount="250000000000000ppica"
    centaurid collect-gentxs --home "$CHAIN_DATA"  --gentx-dir "$CHAIN_DATA/config/gentx"
else
    echo "WARNING: REUSING EXISTING DATA FOLDER"
fi