ALICE_ADDRESS=$(cosmos_sdk_show_key_for "ALICE" "centaurid")
$BINARY tx ibc-transfer  transfer transfer channel-0 "$ALICE_ADDRESS" 1000000000000$FEE --from=ALICE --gas=1052427 --fees="10000$FEE" -y