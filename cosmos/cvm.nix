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
          ${sh.export networks.pica.devnet}
          ${sh.export networks.devnet.mnemonics}
          source ${./cosmos_sdk.sh}          
          ${builtins.readFile ./centauri-init.sh}
        '';
      };
    };
  };
}
