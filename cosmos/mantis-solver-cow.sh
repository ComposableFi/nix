# watch --no-title  --interval=12 --exec mantis simulate --rpc-centauri "$RPC_CENTAURI" --grpc-centauri "$GRPC_CENTAURI" --order-contract "$ORDER_CONTRACT" --wallet "$WALLET" --coins "10000ibc/ED07A3391A112B175915CD8FAF43A2DA8E4790EDE12566649D0C2F97716B8518,10000ppica" --cvm-contract "$CVM_CONTRACT" --main-chain-id="$CHAIN_ID"

mantis solve --order-contract "$ORDER_CONTRACT"