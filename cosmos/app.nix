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
      osmosis-to-centauri-transfer = pkgs.writeShellApplication {
        name = "osmosis-to-centauri-transfer";
        runtimeInputs = runtimeInputs;
        text = ''
          ${sh.export networks.devnet.directories}
          ${sh.export networks.osmosis.devnet}
          ${sh.export networks.devnet.mnemonics}
          ${builtins.readFile ./cosmos_sdk.sh}
          ${builtins.readFile ./osmosis-to-centauri-transfer.sh}
        '';
      };

      centauri-to-osmosis-transfer = pkgs.writeShellApplication {
        name = "centauri-to-osmosis-transfer";
        runtimeInputs = runtimeInputs;
        text = ''
          ${sh.export networks.devnet.directories}
          ${sh.export networks.pica.devnet}
          ${sh.export networks.devnet.mnemonics}
          ${builtins.readFile ./cosmos_sdk.sh}
          ${builtins.readFile ./centauri-to-osmosis-transfer.sh}
        '';
      };
    };
  };
}
