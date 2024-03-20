{ self, ... }: {
  perSystem =
    { config
    , self'
    , inputs'
    , system
    , pkgs
    , runtimeInputs
    , ...
    }: {
      packages =
        let
          networks = pkgs.networksLib.networks;
          sh = pkgs.networksLib.sh;
        in
        {
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

          osmosisd-pools-init = pkgs.writeShellApplication {
            name = "osmosisd-pools-init";
            runtimeInputs = runtimeInputs;
            text = ''
              ${sh.export networks.osmosis.devnet}


            '';
          };

        };
    };
}
