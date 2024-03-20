{ self, ... }: {
  perSystem = { config, self', inputs', system, pkgs, runtimeInputs,... }: {
    devShells = {
      default = pkgs.mkShell {
          buildInputs = runtimeInputs;
       };
    };
  };
}