{self, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    system,
    pkgs,
    runtimeInputs,
    ...
  }: {
    packages = let
      networks = pkgs.networksLib.networks;
      sh = pkgs.networksLib.sh;
    in {
      centauri-cvm-init = pkgs.writeShellApplication {
        name = "centauri-init";
        runtimeInputs = runtimeInputs;
        text = ''
          CW_CVM_OUTPOST_WASM=${pkgs.cw-cvm-outpost}/lib/cw_cvm_outpost.wasm
          CW_CVM_EXECUTOR_WASM=${pkgs.cw-cvm-executor}/lib/cw_cvm_executor.wasm
          CW_MANTIS_ORDER_WASM=${pkgs.cw-mantis-order}/lib/cw_mantis_order.wasm
          export CW_CVM_OUTPOST_WASM
          export CW_CVM_EXECUTOR_WASM
          export CW_MANTIS_ORDER_WASM             
          ${sh.export networks.pica.devnet}
          ${sh.export networks.devnet.mnemonics}
          ${builtins.readFile ./cosmos_sdk.sh}          
          ${builtins.readFile ./cvm-init.sh}
        '';
      };

      osmosis-cvm-init = pkgs.writeShellApplication {
        name = "osmosis-init";
        runtimeInputs = runtimeInputs;
        text = ''
          CW_CVM_OUTPOST_WASM=${pkgs.cw-cvm-outpost}/lib/cw_cvm_outpost.wasm
          CW_CVM_EXECUTOR_WASM=${pkgs.cw-cvm-executor}/lib/cw_cvm_executor.wasm
          CW_MANTIS_ORDER_WASM=${pkgs.cw-mantis-order}/lib/cw_mantis_order.wasm
          export CW_CVM_OUTPOST_WASM
          export CW_CVM_EXECUTOR_WASM
          export CW_MANTIS_ORDER_WASM             
          ${sh.export networks.osmosis.devnet}
          ${sh.export networks.devnet.mnemonics}
          OSMOSISD_ENVIRONMENT="$HOME/.osmosisd"          
          export OSMOSISD_ENVIRONMENT           
          ${builtins.readFile ./cosmos_sdk.sh}          
          ${builtins.readFile ./cvm-init.sh}
        '';
      };

    };
  };
}



      # osmosisd-cvm-config = pkgs.writeShellApplication {
      #   name = "osmosisd-cvm-config";
      #   text = ''

      #     ${bashTools.export pkgs.networksLib.osmosis.devnet}
      #     KEY=${cosmosTools.cvm.osmosis}

      #     CENTAURI_OUTPOST_CONTRACT_ADDRESS=$(cat ${pkgs.networksLib.pica.devnet.CHAIN_DATA}/outpost_contract_address)
      #     CENTAURI_EXECUTOR_CODE_ID=$(cat ${pkgs.networksLib.pica.devnet.CHAIN_DATA}/executor_code_id)
      #     OSMOSIS_OUTPOST_CONTRACT_ADDRESS=$(cat "$HOME/.osmosisd/outpost_contract_address")
      #     OSMOSIS_EXECUTOR_CODE_ID=$(cat "$HOME/.osmosisd/executor_code_id")
      #     NEUTRON_OUTPOST_CONTRACT_ADDRESS=$(cat "${pkgs.networksLib.pica.devnet.CHAIN_DATA}/outpost_contract_address")
      #     NEUTRON_EXECUTOR_CODE_ID=$(cat "${pkgs.networksLib.pica.devnet.CHAIN_DATA}/executor_code_id")

      #     FORCE_CONFIG=$(cat << EOF
      #       ${builtins.readFile ../cvm.json}
      #     EOF
      #     )
      #     "$BINARY" tx wasm execute "$OSMOSIS_OUTPOST_CONTRACT_ADDRESS" "$FORCE_CONFIG" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas 25000000 --fees 920000166"$FEE" --keyring-backend test  --home "$CHAIN_DATA" --from "$KEY" --keyring-dir "$KEYRING_TEST" ${log}


      #     sleep "$BLOCK_SECONDS"
      #     "$BINARY" query wasm contract-state all "$OSMOSIS_OUTPOST_CONTRACT_ADDRESS" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --home "$CHAIN_DATA"
      #   '';
      # centaurid-cvm-config = pkgs.writeShellApplication {
      #   name = "centaurid-cvm-config";
      #   runtimeInputs = devnetTools.withBaseContainerTools ++ [
      #     centaurid
      #     pkgs.jq
      #     self.inputs.cvm.packages."${system}".cw-cvm-executor
      #     self.inputs.cvm.packages."${system}".cw-cvm-outpost
      #   ];

      #   text = ''
      #     KEY=${cosmosTools.cvm.centauri}
      #     ${bashTools.export pkgs.networksLib.pica.devnet}
      #     PORT=26657
      #     BLOCK_SECONDS=5
      #     FEE=ppica
      #     BINARY=centaurid

      #     CENTAURI_OUTPOST_CONTRACT_ADDRESS=$(cat $CHAIN_DATA/outpost_contract_address)
      #     CENTAURI_EXECUTOR_CODE_ID=$(cat $CHAIN_DATA/executor_code_id)
      #     OSMOSIS_OUTPOST_CONTRACT_ADDRESS=$(cat "$HOME/.osmosisd/outpost_contract_address")
      #     OSMOSIS_EXECUTOR_CODE_ID=$(cat "$HOME/.osmosisd/executor_code_id")
      #     NEUTRON_OUTPOST_CONTRACT_ADDRESS=$(cat "$CHAIN_DATA/outpost_contract_address")
      #     NEUTRON_EXECUTOR_CODE_ID=$(cat "$CHAIN_DATA/executor_code_id")

      #     FORCE_CONFIG=$(cat << EOF
      #         ${builtins.readFile ./../cvm.json}
      #     EOF
      #     )

      #     "$BINARY" tx wasm execute "$CENTAURI_OUTPOST_CONTRACT_ADDRESS" "$FORCE_CONFIG" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$PORT" --output json --yes --gas 25000000 --fees 920000166"$FEE" ${log} --keyring-backend test  --home "$CHAIN_DATA" --from APPLICATION1 --keyring-dir "$KEYRING_TEST" ${log}
      #     sleep $BLOCK_SECONDS
      #     "$BINARY" query wasm contract-state all "$CENTAURI_OUTPOST_CONTRACT_ADDRESS" --chain-id="$CHAIN_ID"  --node "tcp://localhost:$PORT" --output json --home "$CHAIN_DATA"
      #   '';
      # };