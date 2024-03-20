      osmosis-cvm-init = pkgs.writeShellApplication {
        name = "osmosis-cvm-init";
        runtimeInputs =
          devnetTools.withBaseContainerTools
          ++ [osmosisd pkgs.jq pkgs.dasel];
        text = ''
          ${bashTools.export pkgs.networksLib.osmosis.devnet}
          # [osmosis-cvm-init	] OsmosisApp is not ready; please wait for first block: invalid height
          sleep 16
          KEY=${cosmosTools.cvm.osmosis}

          function init_cvm() {
            local INSTANTIATE=$1
            echo $NETWORK_ID
            "$BINARY" tx wasm store  "${
            self.inputs.cvm.packages."${system}".cw-cvm-outpost
          }/lib/cw_cvm_outpost.wasm" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas 25000000 --fees 920000166$FEE --log_level=info --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST"
            GATEWAY_CODE_ID=1

            sleep "$BLOCK_SECONDS"
            "$BINARY" tx wasm store  "${
            self.inputs.cvm.packages."${system}".cw-cvm-executor
          }/lib/cw_cvm_executor.wasm" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas 25000000 --fees 920000166$FEE --log_level=info --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST"
            EXECUTOR_CODE_ID=2

            sleep "$BLOCK_SECONDS"
            "$BINARY" tx wasm store  ${
            self.inputs.cosmos.packages.${system}.cw20-base
          }/lib/cw20_base.wasm --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas 25000000 --fees 920000166$FEE --log_level=info --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST"

            sleep "$BLOCK_SECONDS"

            "$BINARY" tx wasm instantiate2 $GATEWAY_CODE_ID "$INSTANTIATE" "1234" --label "composable_cvm_outpost" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas 25000000 --fees 920000166$FEE --log_level=info --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST" --admin "$KEY"

            sleep "$BLOCK_SECONDS"
            OUTPOST_CONTRACT_ADDRESS=$("$BINARY" query wasm list-contract-by-code "$GATEWAY_CODE_ID" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --home "$CHAIN_DATA" | dasel --read json '.contracts.[0]' --write yaml)
            echo "$OUTPOST_CONTRACT_ADDRESS" | tee "$CHAIN_DATA/outpost_contract_address"
            echo "$EXECUTOR_CODE_ID" > "$CHAIN_DATA/executor_code_id"
          }

          INSTANTIATE=$(cat << EOF
              {
                  "admin" : "$KEY",
                  "network_id" : $NETWORK_ID
              }
          EOF
          )

          init_cvm "$INSTANTIATE"
        '';
      };


      osmosisd-cvm-config = pkgs.writeShellApplication {
        name = "osmosisd-cvm-config";
        text = ''

          ${bashTools.export pkgs.networksLib.osmosis.devnet}
          KEY=${cosmosTools.cvm.osmosis}

          CENTAURI_OUTPOST_CONTRACT_ADDRESS=$(cat ${pkgs.networksLib.pica.devnet.CHAIN_DATA}/outpost_contract_address)
          CENTAURI_EXECUTOR_CODE_ID=$(cat ${pkgs.networksLib.pica.devnet.CHAIN_DATA}/executor_code_id)
          OSMOSIS_OUTPOST_CONTRACT_ADDRESS=$(cat "$HOME/.osmosisd/outpost_contract_address")
          OSMOSIS_EXECUTOR_CODE_ID=$(cat "$HOME/.osmosisd/executor_code_id")
          NEUTRON_OUTPOST_CONTRACT_ADDRESS=$(cat "${pkgs.networksLib.pica.devnet.CHAIN_DATA}/outpost_contract_address")
          NEUTRON_EXECUTOR_CODE_ID=$(cat "${pkgs.networksLib.pica.devnet.CHAIN_DATA}/executor_code_id")

          FORCE_CONFIG=$(cat << EOF
            ${builtins.readFile ../cvm.json}
          EOF
          )
          "$BINARY" tx wasm execute "$OSMOSIS_OUTPOST_CONTRACT_ADDRESS" "$FORCE_CONFIG" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas 25000000 --fees 920000166"$FEE" --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST" ${log}


          sleep "$BLOCK_SECONDS"
          "$BINARY" query wasm contract-state all "$OSMOSIS_OUTPOST_CONTRACT_ADDRESS" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --home "$CHAIN_DATA"
        '';
      };
    };
  };
}
