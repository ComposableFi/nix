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
    devShells = {
      default = pkgs.mkShell {
        buildInputs = runtimeInputs;
        shellHook = ''
          CW_CVM_OUTPOST_WASM=${pkgs.cw-cvm-outpost}/lib/cw_cvm_outpost.wasm
          export CW_CVM_OUTPOST_WASM
          HOME=${pkgs.networksLib.networks.osmosis.devnet.HOME}
          OSMOSISD_ENVIRONMENT="~/.osmosisd"
          export HOME
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
    };
  };
}
