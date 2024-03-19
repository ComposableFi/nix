{ self, ... }: {
  perSystem = { config, self', inputs', system, pkgs, ... }: {
    devShells = {
      default = pkgs.mkShell {
          buildInputs = with pkgs; [
            getoptions
          ];
       };
    };
  };
}