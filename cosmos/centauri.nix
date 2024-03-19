{ self, ... }: {
  perSystem = { config, self', inputs', system, pkgs, ... }: {
    packages = 
        let 
          networks = pkgs.networksLib.networks;
          sh = pkgs.networksLib.sh;
        in
        {
        centauri-init = pkgs.writeShellApplication {
          name = "centauri-init";
          runtimeInputs = with pkgs; [
            pkgs.getoptions
          ];

          text = ''
          ${sh.export networks.pica.devnet}
          ${sh.export networks.devnet.mnemonics}
          ${builtins.readFile ./centauri-init.sh}
          '';
        };
    };
  };
}
