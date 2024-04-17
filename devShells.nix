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
    devShells = rec {
      devnet = pkgs.mkShell {
        buildInputs = runtimeInputs;
        shellHook = let
          networks = pkgs.networksLib.networks;
          sh = pkgs.networksLib.sh;
        in ''
          ${sh.export networks.devnet.directories}
          ${builtins.readFile ./cosmos/cosmos_sdk.sh}
          CW_CVM_OUTPOST_WASM=${pkgs.cw-cvm-outpost}/lib/cw_cvm_outpost.wasm
          export CW_CVM_OUTPOST_WASM
          OSMOSISD_ENVIRONMENT="$HOME/.osmosisd"
          export OSMOSISD_ENVIRONMENT
          echo 'chain-id = "osmosis-dev"' > ~/.osmosisd/config/client.toml
          echo 'keyring-backend = "test"' >> ~/.osmosisd/config/client.toml
          echo 'output = "json"' >> ~/.osmosisd/config/client.toml
          echo 'broadcast-mode = "sync"' >> ~/.osmosisd/config/client.toml
          echo 'human-readable-denoms-input = false' >> ~/.osmosisd/config/client.toml
          echo 'human-readable-denoms-output = false' >> ~/.osmosisd/config/client.toml
          echo 'gas = ""' >> ~/.osmosisd/config/client.toml
          echo 'gas-prices = ""' >> ~/.osmosisd/config/client.toml
          echo 'gas-adjustment = ""' >> ~/.osmosisd/config/client.toml
          echo 'fees = ""' >> ~/.osmosisd/config/client.toml
          echo 'node = "${pkgs.networksLib.networks.osmosis.devnet.NODE}"' >> ~/.osmosisd/config/client.toml
        '';
      };
      default = devnet;
      mainnet = let
        networks = pkgs.networksLib.networks;
        sh = pkgs.networksLib.sh;
      in
        pkgs.mkShell {
          buildInputs = runtimeInputs;
          EXECUTOR_WASM_FILE = "${
            self.inputs.composable-vm.packages."${system}".cw-cvm-executor
          }/lib/cw_cvm_executor.wasm";
          OUTPOST_WASM_FILE = "${
            self.inputs.composable-vm.packages."${system}".cw-cvm-outpost
          }/lib/cw_cvm_outpost.wasm";
          ORDER_WASM_FILE = "${
            self.inputs.composable-vm.packages."${system}".cw-mantis-order
          }/lib/cw_mantis_order.wasm";
          shellHook = ''
            rm --force --recursive ~/.banksy
            mkdir --parents ~/.banksy/config
            echo 'keyring-backend = "os"' >> ~/.banksy/config/client.toml
            echo 'output = "json"' >> ~/.banksy/config/client.toml
            echo 'node = "${networks.pica.mainnet.NODE}"' >> ~/.banksy/config/client.toml
            echo 'chain-id = "${networks.pica.mainnet.CHAIN_ID}"' >> ~/.banksy/config/client.toml
            rm ~/.osmosisd/config/client.toml
            osmosisd set-env mainnet
          '';
        };
    };
  };
}
