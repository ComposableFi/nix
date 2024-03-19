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

          parser_definition() {
            setup   REST help:usage -- "Usage: example.sh [options]... [arguments]..."
            msg --  'Options:'
            option  FRESH  -f --fresh on:true  -- "takes one optional argument"
          }
          eval "$(getoptions parser_definition) exit 1"
          env
          
          if test "$FRESH" != "false"
          then
            echo ${networks.pica.devnet.CHAIN_DATA}
            rm --force --recursive ${networks.pica.devnet.CHAIN_DATA}
          fi
          '';
        };
    };
  };
}
