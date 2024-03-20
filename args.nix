{self, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    system,
    pkgs,
    ...
  }: {
    _module.args = {
      runtimeInputs = with pkgs; [
        bun
        centauri
        cw-cvm-executor
        cw-cvm-outpost
        cw-mantis-order
        dasel
        getoptions
        gex
        grpcurl
        jq
        nix-tree
        osmosis
        hermes
      ];
      pkgs = import self.inputs.nixpkgs {
        inherit system;
        overlays = with self.inputs; [
          process-compose.overlays.default
          networks.overlays.default
          cosmos.overlays.default
          # cosmos.overlays.cosmosNixPackages
          (final: prev: {
            cw-cvm-executor = self.inputs.composable-vm.packages."${system}".cw-cvm-executor;
            cw-cvm-outpost = self.inputs.composable-vm.packages."${system}".cw-cvm-outpost;
            cw-mantis-order = self.inputs.composable-vm.packages."${system}".cw-mantis-order;
          })
        ];
      };
    };
  };
}
#       centauri-devnet = self.inputs.devenv.lib.mkShell {
#         inherit pkgs;
#         inputs = self.inputs;
#         modules = [
#           rec {
#             packages = [self'.packages.centaurid];
#             env =
#               networks.pica.devnet
#               // {
#                 DIR = "devnet/.centaurid";
#                 NODE = "tcp://localhost:26657";
#                 EXECUTOR_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-cvm-executor
#                 }/lib/cw_cvm_executor.wasm";
#                 OUTPOST_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-cvm-gateway
#                 }/lib/cw_cvm_gateway.wasm";
#               };
#             enterShell = ''
#               rm --force --recursive ~/.centauri
#               mkdir --parents ~/.centauri/config
#               echo 'keyring-backend = "test"' >> ~/.centauri/config/client.toml
#               echo 'output = "json"' >> ~/.centauri/config/client.toml
#               echo 'node = "${env.NODE}"' >> ~/.centauri/config/client.toml
#               echo 'chain-id = "${env.CHAIN_ID}"' >> ~/.centauri/config/client.toml
#               ${bashTools.export networks.devnet.mnemonics}
#               echo "$APPLICATION1" | "$BINARY" keys add APPLICATION1 --recover --keyring-backend test --output json
#               echo "$DEMO_MNEMONIC_1" | "$BINARY" keys add DEMO_MNEMONIC_1 --recover --keyring-backend test --output json
#             '';
#           }
#         ];
#       };
#       centauri-testnet = self.inputs.devenv.lib.mkShell {
#         inherit pkgs;
#         inputs = self.inputs;
#         modules = [
#           {
#             packages = [self'.packages.centaurid];
#             env = {
#               FEE = "ppica";
#               NETWORK_ID = 2;
#               CHAIN_ID = "banksy-testnet-3";
#               DIR = "testnet/.centaurid";
#               BINARY = "centaurid";
#               NODE = "https://rpc-t.composable.nodestake.top:443";
#               EXECUTOR_WASM_FILE = "${
#                 self.inputs.cvm.packages."${system}".cw-cvm-executor
#               }/lib/cw_cvm_executor.wasm";
#               OUTPOST_WASM_FILE = "${
#                 self.inputs.cvm.packages."${system}".cw-cvm-gateway
#               }/lib/cw_cvm_gateway.wasm";
#             };
#           }
#         ];
#       };
#       centauri-mainnet = self.inputs.devenv.lib.mkShell {
#         inherit pkgs;
#         inputs = self.inputs;
#         modules = [
#           {
#             packages = [self'.packages.centaurid];
#             env =
#               networks.pica.mainnet
#               // {
#                 EXECUTOR_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-cvm-executor
#                 }/lib/cw_cvm_executor.wasm";
#                 OUTPOST_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-cvm-gateway
#                 }/lib/cw_cvm_gateway.wasm";
#                 ORDER_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-mantis-order
#                 }/lib/cw_mantis_order.wasm";
#               };
#             enterShell = ''
#               rm --force --recursive ~/.banksy
#               mkdir --parents ~/.banksy/config
#               echo 'keyring-backend = "os"' >> ~/.banksy/config/client.toml
#               echo 'output = "json"' >> ~/.banksy/config/client.toml
#               echo 'node = "${networks.pica.mainnet.NODE}"' >> ~/.banksy/config/client.toml
#               echo 'chain-id = "centauri-1"' >> ~/.banksy/config/client.toml
#             '';
#           }
#         ];
#       };
#       osmosis-mainnet = self.inputs.devenv.lib.mkShell {
#         inherit pkgs;
#         inputs = self.inputs;
#         modules = [
#           {
#             packages = [self'.packages.osmosisd];
#             env =
#               networks.osmosis.mainnet
#               // {
#                 EXECUTOR_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-cvm-executor
#                 }/lib/cw_cvm_executor.wasm";
#                 OUTPOST_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-cvm-gateway
#                 }/lib/cw_cvm_gateway.wasm";
#                 ORDER_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-mantis-order
#                 }/lib/cw_mantis_order.wasm";
#               };
#             enterShell = ''
#               rm ~/.osmosisd/config/client.toml
#               osmosisd set-env mainnet
#             '';
#           }
#         ];
#       };
#       osmosis-testnet = self.inputs.devenv.lib.mkShell {
#         inherit pkgs;
#         inputs = self.inputs;
#         modules = [
#           {
#             packages = [self'.packages.osmosisd];
#             env =
#               osmosis.env.testnet
#               // {
#                 EXECUTOR_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-cvm-executor
#                 }/lib/cw_cvm_executor.wasm";
#                 OUTPOST_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-cvm-gateway
#                 }/lib/cw_cvm_gateway.wasm";
#                 FEE = "uatom";
#               };
#           }
#         ];
#       };
#       osmosis-local = self.inputs.devenv.lib.mkShell {
#         inherit pkgs;
#         inputs = self.inputs;
#         modules = [
#           rec {
#             packages = [self'.packages.osmosisd];
#             env =
#               osmosis.env.testnet
#               // {
#                 EXECUTOR_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-cvm-executor
#                 }/lib/cw_cvm_executor.wasm";
#                 OUTPOST_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-cvm-gateway
#                 }/lib/cw_cvm_gateway.wasm";
#                 NODE = "tcp://localhost:${
#                   builtins.toString networks.osmosis.devnet.PORT
#                 }";
#                 FEE = "uatom";
#               };
#             enterShell = ''
#               osmosisd set-env localnet
#               echo 'chain-id = "osmosis-dev"' > ~/.osmosisd-local/config/client.toml
#               echo 'keyring-backend = "test"' >> ~/.osmosisd-local/config/client.toml
#               echo 'output = "json"' >> ~/.osmosisd-local/config/client.toml
#               echo 'broadcast-mode = "block"' >> ~/.osmosisd-local/config/client.toml
#               echo 'human-readable-denoms-input = false' >> ~/.osmosisd-local/config/client.toml
#               echo 'human-readable-denoms-output = false' >> ~/.osmosisd-local/config/client.toml
#               echo 'gas = ""' >> ~/.osmosisd-local/config/client.toml
#               echo 'gas-prices = ""' >> ~/.osmosisd-local/config/client.toml
#               echo 'gas-adjustment = ""' >> ~/.osmosisd-local/config/client.toml
#               echo 'fees = ""' >> ~/.osmosisd-local/config/client.toml
#               echo 'node = "${env.NODE}"' >> ~/.osmosisd-local/config/client.toml
#             '';
#           }
#         ];
#       };
#       osmosis-devnet = self.inputs.devenv.lib.mkShell {
#         inherit pkgs;
#         inputs = self.inputs;
#         modules = [
#           rec {
#             packages = [self'.packages.osmosisd];
#             env =
#               osmosis.env.remote-devnet
#               // {
#                 EXECUTOR_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-cvm-executor
#                 }/lib/cw_cvm_executor.wasm";
#                 OUTPOST_WASM_FILE = "${
#                   self.inputs.cvm.packages."${system}".cw-cvm-gateway
#                 }/lib/cw_cvm_gateway.wasm";
#               };
#             enterShell = ''
#               osmosisd set-env localnet
#               echo 'chain-id = "osmosis-dev"' > ~/.osmosisd-local/config/client.toml
#               echo 'keyring-backend = "test"' >> ~/.osmosisd-local/config/client.toml
#               echo 'output = "json"' >> ~/.osmosisd-local/config/client.toml
#               echo 'broadcast-mode = "block"' >> ~/.osmosisd-local/config/client.toml
#               echo 'human-readable-denoms-input = false' >> ~/.osmosisd-local/config/client.toml
#               echo 'human-readable-denoms-output = false' >> ~/.osmosisd-local/config/client.toml
#               echo 'gas = ""' >> ~/.osmosisd-local/config/client.toml
#               echo 'gas-prices = ""' >> ~/.osmosisd-local/config/client.toml
#               echo 'gas-adjustment = ""' >> ~/.osmosisd-local/config/client.toml
#               echo 'fees = ""' >> ~/.osmosisd-local/config/client.toml
#               echo 'node = "${env.NODE}"' >> ~/.osmosisd-local/config/client.toml
#             '';
#           }
#         ];
#       };
#     };
#   };
# }

