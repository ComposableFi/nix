RUST_LOG=debug
mkdir --parents "$RELAY_DATA"
HOME=$RELAY_DATA
export HOME
MNEMONIC_FILE="$HOME/.hermes/mnemonics/relayer.txt"
export MNEMONIC_FILE
echo "$HOME/.hermes/mnemonics/"
mkdir --parents "$HOME/.hermes/mnemonics/"
cp --dereference --no-preserve=mode,ownership --force "$HERMES_CONFIG" "$HOME/.hermes/config.toml"
echo "$RLY_MNEMONIC_3" > "$MNEMONIC_FILE"
hermes keys add --chain "$CHAIN_ID_A" --mnemonic-file "$MNEMONIC_FILE" --key-name "$CHAIN_ID_A" --overwrite
hermes keys add --chain "$CHAIN_ID_B" --mnemonic-file "$MNEMONIC_FILE" --key-name "$CHAIN_ID_B" --overwrite
export RUST_LOG
hermes create channel --a-chain "$CHAIN_ID_A" --b-chain "$CHAIN_ID_B" --a-port transfer --b-port transfer --new-client-connection --yes