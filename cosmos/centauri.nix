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
      centauri-init = pkgs.writeShellApplication {
        name = "centauri-init";
        runtimeInputs = runtimeInputs;

        text = ''
          ${sh.export networks.pica.devnet}
          ${sh.export networks.devnet.mnemonics}
          ${builtins.readFile ./centauri-init.sh}
        '';
      };

      centauri-start = pkgs.writeShellApplication {
        name = "centaurid-start";
        runtimeInputs = runtimeInputs;
        text = ''
          ${sh.export networks.pica.devnet}
          ${sh.export networks.devnet.mnemonics}
          ${builtins.readFile ./centauri-start.sh}
        '';
      };
      osmosis-init = pkgs.writeShellApplication {
        name = "osmosis-init";
        runtimeInputs = runtimeInputs;

        text = ''
          ${sh.export networks.osmosis.devnet}
          ${sh.export networks.devnet.mnemonics}
          ${builtins.readFile ./osmosis-init.sh}
        '';
      };

      osmosis-start = pkgs.writeShellApplication {
        name = "osmosis-start";
        runtimeInputs = runtimeInputs;
        text = ''
          ${sh.export networks.osmosis.devnet}
          ${sh.export networks.devnet.mnemonics}
          ${builtins.readFile ./osmosis-start.sh}
        '';
      };
    };
  };
}
