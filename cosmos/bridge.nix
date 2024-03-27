{self, ...}: {
  perSystem = {
    self',
    pkgs,
    lib,
    system,
    runtimeInputs,
    ...
  }: let
    networks = pkgs.networksLib.networks;
    sh = pkgs.networksLib.sh;
    cosmosLib = pkgs.cosmosLib;
    hermes-config =
      (cosmosLib.hermesModuleConfigToml {
        modules = [
          {
            config.hermes.config = {
              global.log_level = "debug";
              mode.clients = {
                misbehaviour = true;
                refresh = true;
              };
              mode.packets = {
                enabled = true;
                clear_interval = 100;
                clear_on_start = false;
                tx_confirmation = true;
              };
              rest = {
                enabled = true;
                host = "0.0.0.0";
                port = networks.osmosis-centauri.devnet.REST_PORT;
              };
              telemetry = {
                enabled = true;
                host = "0.0.0.0";
                port = networks.osmosis-centauri.devnet.TELEMETRY_PORT;
              };
              chains = [
                {
                  id = networks.pica.devnet.CHAIN_ID;
                  rpc_addr = "http://127.0.0.1:${
                    builtins.toString networks.pica.devnet.CONSENSUS_RPC_PORT
                  }";
                  grpc_addr = "http://127.0.0.1:${
                    builtins.toString networks.pica.devnet.GRPCPORT
                  }";
                  event_source = {
                    mode = "pull";
                    interval = "1s";
                  };
                  rpc_timeout = "30s";
                  account_prefix = "centauri";
                  key_name = networks.pica.devnet.CHAIN_ID;
                  store_prefix = "ibc";
                  default_gas = 100000000;
                  max_gas = 40000000000;
                  gas_price = {
                    price = 0.1;
                    denom = "ppica";
                  };
                  gas_multiplier = 2.0;
                  max_msg_num = 5;
                  max_tx_size = 4097152;
                  clock_drift = "10s";
                  max_block_time = "30s";
                  trusting_period = "640s";
                  trust_threshold = {
                    numerator = "1";
                    denominator = "3";
                  };
                  type = "CosmosSdk";
                  address_type = {derivation = "cosmos";};
                  trusted_node = true;
                  key_store_type = "Test";
                  # default is allow * *
                  # packet_filter = {
                  #   policy = "allow";
                  #   list = [[
                  #     "transfer"
                  #     "channel-*"
                  #   ]];
                  # };
                }
                {
                  id = networks.osmosis.devnet.CHAIN_ID;
                  rpc_addr = "http://127.0.0.1:${
                    builtins.toString networks.osmosis.devnet.CONSENSUS_RPC_PORT
                  }";
                  grpc_addr = "http://127.0.0.1:${
                    builtins.toString networks.osmosis.devnet.GRPCPORT
                  }";
                  event_source = {
                    mode = "pull";
                    interval = "1s";
                  };
                  rpc_timeout = "20s";
                  account_prefix = networks.osmosis.devnet.ACCOUNT_PREFIX;
                  key_name = "osmosis-dev";
                  store_prefix = "ibc";
                  key_store_type = "Test";
                  default_gas = 10000000;
                  max_gas = 2000000000;
                  gas_price = {
                    price = 0.1;
                    denom = "uosmo";
                  };
                  gas_multiplier = 2.0;
                  max_msg_num = 10;
                  max_tx_size = 4097152;
                  clock_drift = "20s";
                  max_block_time = "30s";
                  trusting_period = "640s";
                  trust_threshold = {
                    numerator = "1";
                    denominator = "3";
                  };
                  type = "CosmosSdk";
                  address_type = {derivation = "cosmos";};
                  trusted_node = true;
                }
              ];
            };
          }
        ];
      })
      .config
      .hermes
      .toml;
  in {
    packages = rec {
      osmosis-centauri-init = pkgs.writeShellApplication {
        runtimeInputs = runtimeInputs;
        name = "osmosis-centauri-init";
        text = ''
          ${sh.export networks.devnet.directories}
          ${sh.export networks.osmosis-centauri.devnet}
          ${sh.export networks.devnet.mnemonics}
          HERMES_CONFIG=${builtins.toFile "hermes-config.toml" hermes-config}
          ${builtins.readFile ./osmosis-centauri-init.sh}
        '';
      };

      osmosis-centauri-start = pkgs.writeShellApplication {
        runtimeInputs = runtimeInputs;
        name = "osmosis-centauri-start";
        text = ''
          ${sh.export networks.devnet.directories}
          ${sh.export networks.devnet.mnemonics}
          ${sh.export networks.osmosis-centauri.devnet}
          HOME=$RELAY_DATA
          RUST_LOG=info
          export HOME
          export RUST_LOG
          hermes start
        '';
      };
    };
  };
}
