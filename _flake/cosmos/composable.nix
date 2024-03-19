{ self, ... }: {
  perSystem = { config, self', inputs', pkgs, lib, system
    , devnetTools, cosmosTools, bashTools, centauri
    , ... }:

    let
      log = " --log_level trace --trace ";
      devnet-root-directory = cosmosTools.devnet-root-directory;
      validator-mnemonic = cosmosTools.validators.mnemonic;
      gov = {
        account = "centauri10d07y265gmmuvt4z0w9aw880jnsr700j7g7ejq";
        voting_period = "20s";
        max_deposit_period = "10s";
      };
      native_denom = "ppica";
      name = "centaurid";
      cosmosLib = self.inputs.cosmos.lib {
        inherit pkgs;
        cosmwasm-check = self.inputs.cosmos.packages."${system}".cosmwasm-check;
      };

      centaurid = self.inputs.composable-cosmos.packages."${system}".centaurid;

      ibc-lightclients-wasm-v1-msg-push-new-wasm-code = code: {
        "messages" = [{
          "@type" = "/ibc.lightclients.wasm.v1.MsgPushNewWasmCode";
          "signer" = "${gov.account}";
          "code" = code;
        }];
        "deposit" = "5000000000000000ppica";
        "metadata" = "none";
        "title" = "none";
        "summary" = "none";
      };

      ics10-grandpa-cw-proposal = let
        code = builtins.readFile
          "${self'.packages.ics10-grandpa-cw}/lib/ics10_grandpa_cw.wasm.gz.txt";
        code-file = builtins.toFile "ics10_grandpa_cw.wasm.json"
          (builtins.toJSON
            (ibc-lightclients-wasm-v1-msg-push-new-wasm-code code));
      in pkgs.stdenv.mkDerivation {
        name = "ics10-grandpa-cw-proposal";
        dontUnpack = true;
        installPhase = ''
          mkdir --parents $out
          cp ${code-file} $out/ics10_grandpa_cw.wasm.json
        '';
      };
      centaurid-init = pkgs.writeShellApplication {
        name = "centaurid-init";
        runtimeInputs = devnetTools.withBaseContainerTools ++ [
          centaurid
          pkgs.jq
          self.inputs.cvm.packages."${system}".cw-cvm-executor
          self.inputs.cvm.packages."${system}".cw-cvm-outpost
        ];

        text = ''
          ${bashTools.export pkgs.networksLib.pica.devnet}
          VALIDATOR_KEY=$("$BINARY" keys show "VAL_MNEMONIC_1" --keyring-backend=test --keyring-dir="$KEYRING_TEST" --output=json | jq .address -r )

          "$BINARY" tx gov submit-proposal ${ics10-grandpa-cw-proposal}/ics10_grandpa_cw.wasm.json --from="$VALIDATOR_KEY"  --keyring-backend test --gas 9021526220000 --fees 92000000166$FEE --keyring-dir "$KEYRING_TEST" --chain-id "$CHAIN_ID" --yes --home "$CHAIN_DATA" --output json
          sleep $BLOCK_SECONDS
          "$BINARY" query auth module-account gov --chain-id "$CHAIN_ID" --node tcp://localhost:$CONSENSUS_RPC_PORT --home "$CHAIN_DATA" | jq '.account.base_account.address' --raw-output
          PROPOSAL_ID=1
          "$BINARY" tx gov vote $PROPOSAL_ID yes --from "$VALIDATOR_KEY"  --keyring-backend test --gas 9021526220000 --fees 92000000166$FEE --keyring-dir "$KEYRING_TEST" --chain-id "$CHAIN_ID" --yes --home "$CHAIN_DATA" --output json
          sleep 20
          "$BINARY" query gov proposal $PROPOSAL_ID --chain-id "$CHAIN_ID" --node tcp://localhost:$CONSENSUS_RPC_PORT --home "$CHAIN_DATA" | jq '.status'
          sleep $BLOCK_SECONDS
          "$BINARY" query 08-wasm all-wasm-code --chain-id "$CHAIN_ID" --home "$CHAIN_DATA" --output json --node tcp://localhost:$CONSENSUS_RPC_PORT | jq '.code_ids[0]' --raw-output | tee "$CHAIN_DATA/code_id"
        '';
      };

      centaurid-cvm-config = pkgs.writeShellApplication {
        name = "centaurid-cvm-config";
        runtimeInputs = devnetTools.withBaseContainerTools ++ [
          centaurid
          pkgs.jq
          self.inputs.cvm.packages."${system}".cw-cvm-executor
          self.inputs.cvm.packages."${system}".cw-cvm-outpost
        ];

        text = ''
          KEY=${cosmosTools.cvm.centauri}
          ${bashTools.export pkgs.networksLib.pica.devnet}
          PORT=26657
          BLOCK_SECONDS=5
          FEE=ppica
          BINARY=centaurid

          CENTAURI_OUTPOST_CONTRACT_ADDRESS=$(cat $CHAIN_DATA/outpost_contract_address)
          CENTAURI_EXECUTOR_CODE_ID=$(cat $CHAIN_DATA/executor_code_id)
          OSMOSIS_OUTPOST_CONTRACT_ADDRESS=$(cat "$HOME/.osmosisd/outpost_contract_address")
          OSMOSIS_EXECUTOR_CODE_ID=$(cat "$HOME/.osmosisd/executor_code_id")
          NEUTRON_OUTPOST_CONTRACT_ADDRESS=$(cat "$CHAIN_DATA/outpost_contract_address")
          NEUTRON_EXECUTOR_CODE_ID=$(cat "$CHAIN_DATA/executor_code_id")

          FORCE_CONFIG=$(cat << EOF
              ${builtins.readFile ./../cvm.json}
          EOF
          )

          "$BINARY" tx wasm execute "$CENTAURI_OUTPOST_CONTRACT_ADDRESS" "$FORCE_CONFIG" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$PORT" --output json --yes --gas 25000000 --fees 920000166"$FEE" ${log} --keyring-backend test  --home "$CHAIN_DATA" --from APPLICATION1 --keyring-dir "$KEYRING_TEST" ${log}
          sleep $BLOCK_SECONDS
          "$BINARY" query wasm contract-state all "$CENTAURI_OUTPOST_CONTRACT_ADDRESS" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$PORT" --output json --home "$CHAIN_DATA"
        '';
      };

      centaurid-cvm-init = pkgs.writeShellApplication {
        name = "centaurid-cvm-init";
        runtimeInputs = devnetTools.withBaseContainerTools ++ [
          centaurid
          pkgs.jq
          self.inputs.cvm.packages."${system}".cw-cvm-executor
          self.inputs.cvm.packages."${system}".cw-cvm-outpost
        ];

        text = ''
          ${bashTools.export pkgs.networksLib.pica.devnet}
          KEY=${cosmosTools.cvm.centauri}

          if [[ $(curl "127.0.0.1:$CONSENSUS_RPC_PORT/block" | jq .result.block.header.height -r) -lt 5 ]]; then
           sleep 5
          fi

          function init_cvm() {
              local INSTANTIATE=$1
              "$BINARY" tx wasm store  "${
                self.inputs.cvm.packages."${system}".cw-cvm-outpost
              }/lib/cw_cvm_outpost.wasm" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --yes --gas 25000000 --fees 920000166$FEE ${log} --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST"
              GATEWAY_CODE_ID=1

              sleep $BLOCK_SECONDS
              "$BINARY" tx wasm store  "${
                self.inputs.cvm.packages."${system}".cw-cvm-executor
              }/lib/cw_cvm_executor.wasm" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --yes --gas 25000000 --fees 920000166$FEE ${log} --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST"
              EXECUTOR_CODE_ID=2
              sleep $BLOCK_SECONDS
              "$BINARY" tx wasm store  ${
                self.inputs.cosmos.packages.${system}.cw20-base
              }/lib/cw20_base.wasm --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --yes --gas 25000000 --fees 920000166$FEE ${log} --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST"

              sleep $BLOCK_SECONDS
              "$BINARY" tx wasm store  "${
                self.inputs.cvm.packages."${system}".cw-mantis-order
              }/lib/cw_mantis_order.wasm" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --yes --gas 25000000 --fees 920000166$FEE ${log} --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST"
              ORDER_CODE_ID=4

              sleep $BLOCK_SECONDS
              "$BINARY" tx wasm instantiate2 $GATEWAY_CODE_ID "$INSTANTIATE" "2121" --label "composable_cvm_outpost" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --yes --gas 25000000 --fees 920000166$FEE ${log} --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST" --admin "$KEY" --amount 1000000000000$FEE

              sleep $BLOCK_SECONDS
              OUTPOST_CONTRACT_ADDRESS=$("$BINARY" query wasm list-contract-by-code "$GATEWAY_CODE_ID" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --home "$CHAIN_DATA" | dasel --read json '.contracts.[0]' --write yaml)
              echo "$OUTPOST_CONTRACT_ADDRESS" > "$CHAIN_DATA/outpost_contract_address"

              sleep $BLOCK_SECONDS
              echo "{\"cvm_address\": \"$OUTPOST_CONTRACT_ADDRESS\"}"
              "$BINARY" tx wasm instantiate2 $ORDER_CODE_ID "{\"cvm_address\": \"$OUTPOST_CONTRACT_ADDRESS\"}" "2121" --label "composable_mantis_order" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --yes --gas 25000000 --fees 920000166$FEE ${log} --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST" --admin "$KEY" --amount 1000000000000$FEE


              echo "wait for next block"
              sleep $BLOCK_SECONDS
              ORDER_CONTRACT_ADDRESS=$("$BINARY" query wasm list-contract-by-code "$ORDER_CODE_ID" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONSENSUS_RPC_PORT" --output json --home "$CHAIN_DATA" | dasel --read json '.contracts.[0]' --write yaml)
              echo "$ORDER_CONTRACT_ADDRESS" > "$CHAIN_DATA/ORDER_CONTRACT_ADDRESS"

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

      mantis-order-solve = pkgs.writeShellApplication {
        name = "mantis-order-solve";
        runtimeInputs = devnetTools.withBaseContainerTools
          ++ [ centaurid pkgs.jq ];
        text = ''
          ${bashTools.export pkgs.networksLib.pica.devnet}          
          ORDER_CONTRACT_ADDRESS=$(cat "$CHAIN_DATA/ORDER_CONTRACT_ADDRESS")

          sleep $BLOCK_SECONDS
          "$BINARY" tx wasm execute "$ORDER_CONTRACT_ADDRESS" '{"order":{"msg":{"wants":{"denom":"ptest","amount":"10000"},"timeout":1000}}}' --output json --yes --gas 25000000 --fees "1000000000ppica" --amount 1234567890"$FEE" ${log} --from APPLICATION1  ${log}

          sleep $BLOCK_SECONDS
          "$BINARY" tx wasm execute "$ORDER_CONTRACT_ADDRESS" '{"order":{"msg":{"wants":{"denom":"ppica","amount":"10000"},"timeout":1000}}}' --output json --yes --gas 25000000 --fees "1000000000ptest" --amount "1234567890ptest" ${log} --from APPLICATION1  ${log}

          sleep $BLOCK_SECONDS
          "$BINARY" tx wasm execute "$ORDER_CONTRACT_ADDRESS" '{"solve":{"msg":{"routes" : [], "cows":[{"order_id":"2","cow_amount":"100000","given":"100000"},{"order_id":"3","cow_amount":"100000","given":"100000"}],"timeout":5}}}' --output json --yes --gas 25000000 --fees "1000000000ptest" --amount 1234567890"$FEE" ${log} --from APPLICATION1  ${log}

        '';
      };

      centaurid-gen-fresh = pkgs.writeShellApplication {
        name = "centaurid-gen-fresh";
        runtimeInputs = [ centaurid-gen ];
        text = ''
          centaurid-gen fresh
        '';
      };

      centaurid-gen = pkgs.writeShellApplication {
        name = "centaurid-gen";
        text = ''
          centaurid start --rpc.unsafe --rpc.laddr tcp://0.0.0.0:26657 --pruning=nothing --minimum-gas-prices=0.001ppica --home="$CHAIN_DATA" --db_dir="$CHAIN_DATA/data" ${log} --with-tendermint=true --transport=socket --trace-store=$CHAIN_DATA/kvstore.log --grpc.address=0.0.0.0:${
            builtins.toString pkgs.networksLib.pica.devnet.GRPCPORT
          } --grpc.enable=true --grpc-web.enable=false --api.enable=true --cpu-profile=$CHAIN_DATA/cpu-profile.log --p2p.pex=false --p2p.upnp=false
        '';
      };
    in {
      packages = rec {
        inherit centaurid centaurid-gen centaurid-init centaurid-gen-fresh
          ics10-grandpa-cw-proposal centaurid-cvm-init centaurid-cvm-config
          mantis-order-solve;

        centauri-exec = pkgs.writeShellApplication {
          text = ''
            ${bashTools.export pkgs.networksLib.pica.devnet}
            OUTPOST_CONTRACT_ADDRESS=$(cat $CHAIN_DATA/outpost_contract_address)
            MSG=$1
            "$BINARY" tx wasm execute "$OUTPOST_CONTRACT_ADDRESS" "$MSG"  --chain-id="$CHAIN_ID"  --node=s"tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas=25000000 --fees=920000166"$FEE" ${log} --keyring-backend=test  --home="$CHAIN_DATA" --from=${cosmosTools.cvm.moniker} --keyring-dir="$KEYRING_TEST" ${log}
          '';
        };
        centauri-tx = pkgs.writeShellApplication {
          name = "centaurid-cvm-config";
          runtimeInputs = devnetTools.withBaseContainerTools
            ++ [ centaurid pkgs.jq ];

          text = ''
            ${bashTools.export pkgs.networksLib.pica.devnet}
            "$BINARY" tx ibc-transfer transfer transfer channel-0 osmo1x99pkz8mk7msmptegg887wy46vrusl7kk0sudvaf2uh2k8qz7spsyy4mg8 9876543210ppica --chain-id="$CHAIN_ID"  --node "tcp://localhost:$CONENSUS_RPC_PORT" --output=json --yes --gas=25000000 --fees=920000166"$FEE" --keyring-backend=test  --home="$CHAIN_DATA" --from=${cosmosTools.cvm.moniker} --keyring-dir="$KEYRING_TEST" ${log}
          '';
        };
      };
    };
}
