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
          ${builtins.readFile ./cosmos_sdk.sh}          
          ${builtins.readFile ./cvm-init.sh}
        '';
      };

    };
  };
}
