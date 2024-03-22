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
          ${sh.export networks.devnet.directories}
          CW_CVM_OUTPOST_WASM=${pkgs.cw-cvm-outpost}/lib/cw_cvm_outpost.wasm
          CW_CVM_EXECUTOR_WASM=${pkgs.cw-cvm-executor}/lib/cw_cvm_executor.wasm
          CW_MANTIS_ORDER_WASM=${pkgs.cw-mantis-order}/lib/cw_mantis_order.wasm
          export CW_CVM_OUTPOST_WASM
          export CW_CVM_EXECUTOR_WASM
          export CW_MANTIS_ORDER_WASM
          ${sh.export networks.pica.devnet}
          ${sh.export networks.devnet.mnemonics}
          echo "=========================="
          echo "$HOME"
          ${builtins.readFile ./cosmos_sdk.sh}
          ${builtins.readFile ./cvm-init.sh}
        '';
      };

      osmosis-cvm-init = pkgs.writeShellApplication {
        name = "osmosis-init";
        runtimeInputs = runtimeInputs;
        text = ''
          ${sh.export networks.devnet.directories}
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

      cvm-config = pkgs.writeShellApplication {
        name = "cvm-config";
        runtimeInputs = runtimeInputs;
        text = ''
          ${sh.export networks.devnet.directories}
          ${builtins.readFile ./cosmos_sdk.sh}

          ${sh.export networks.osmosis.devnet}
          OSMOSIS_CVM_OUTPOST_CONTRACT_ADDRESS=$(cat "$CHAIN_DATA/CVM_OUTPOST_CONTRACT_ADDRESS")
          OSMOSIS_CW_CVM_EXECUTOR_CODE_ID=$(cat "$CHAIN_DATA/CW_CVM_EXECUTOR_CODE_ID")
          OSMOSIS_ADMIN=$(cosmos_sdk_show_key APPLICATION2)

          ${sh.export networks.pica.devnet}
          CENTAURI_CVM_OUTPOST_CONTRACT_ADDRESS=$(cat "$CHAIN_DATA/CVM_OUTPOST_CONTRACT_ADDRESS")
          CENTAURI_CW_CVM_EXECUTOR_CODE_ID=$(cat "$CHAIN_DATA/CW_CVM_EXECUTOR_CODE_ID")
          echo "$BINARY"
          CENTAURI_ADMIN=$(cosmos_sdk_show_key APPLICATION2)

          CVM_GLT=$(nix eval --expr "import ${./cvm-glt.nix} { OSMOSIS_CVM_OUTPOST_CONTRACT_ADDRESS  = \"$OSMOSIS_CVM_OUTPOST_CONTRACT_ADDRESS\";  OSMOSIS_CW_CVM_EXECUTOR_CODE_ID  = $OSMOSIS_CW_CVM_EXECUTOR_CODE_ID;  OSMOSIS_ADMIN  = \"$OSMOSIS_ADMIN\";  CENTAURI_CVM_OUTPOST_CONTRACT_ADDRESS  = \"$CENTAURI_CVM_OUTPOST_CONTRACT_ADDRESS\";  CENTAURI_CW_CVM_EXECUTOR_CODE_ID  = $CENTAURI_CW_CVM_EXECUTOR_CODE_ID;  CENTAURI_ADMIN  = \"$CENTAURI_ADMIN\"; }" --json --impure --experimental-features 'nix-command flakes')
          echo "$CVM_GLT"
          echo "$CVM_GLT" > "$HOME/cvm-glt.json"
        '';
      };

      centauri-cvm-config = pkgs.writeShellApplication {
        name = "centauri-cvm-config";
        runtimeInputs = runtimeInputs;
        text = ''
          ${sh.export networks.devnet.directories}
          ${builtins.readFile ./cosmos_sdk.sh}
          ${sh.export networks.pica.devnet}

          CVM_GLT=$(cat "$HOME/cvm-glt.json")
          CVM_OUTPOST_CONTRACT_ADDRESS=$(cat "$CHAIN_DATA/CVM_OUTPOST_CONTRACT_ADDRESS")

          "$BINARY" tx wasm execute "$CVM_OUTPOST_CONTRACT_ADDRESS" "$CVM_GLT" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas=25000000 --fees="920000166$FEE" --from="APPLICATION2"

          cosmos_sdk_next

          "$BINARY" query wasm contract-state all "$CVM_OUTPOST_CONTRACT_ADDRESS" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json
        '';
      };
      osmosis-cvm-config = pkgs.writeShellApplication {
        name = "osmosis-cvm-config";
        runtimeInputs = runtimeInputs;
        text = ''
          ${sh.export networks.devnet.directories}
          ${builtins.readFile ./cosmos_sdk.sh}
          ${sh.export networks.osmosis.devnet}

          CVM_GLT=$(cat "$HOME/cvm-glt.json")
          CVM_OUTPOST_CONTRACT_ADDRESS=$(cat "$CHAIN_DATA/CVM_OUTPOST_CONTRACT_ADDRESS")

          "$BINARY" tx wasm execute "$CVM_OUTPOST_CONTRACT_ADDRESS" "$CVM_GLT" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json --yes --gas=25000000 --fees="920000166$FEE" --from="APPLICATION2"

          cosmos_sdk_next

          "$BINARY" query wasm contract-state all "$CVM_OUTPOST_CONTRACT_ADDRESS" --chain-id="$CHAIN_ID"  --node="tcp://localhost:$CONSENSUS_RPC_PORT" --output=json
        '';
      };
    };
  };
}
