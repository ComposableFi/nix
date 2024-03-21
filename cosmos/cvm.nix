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
          export CW_CVM_OUTPOST_WASM             
          ${sh.export networks.pica.devnet}
          ${sh.export networks.devnet.mnemonics}
          ${builtins.readFile ./cosmos_sdk.sh}          
          ${builtins.readFile ./centauri-cvm-init.sh}
        '';
      };
    };
  };
}
