{ self, ... }: {
  perSystem =
    { self', pkgs, systemCommonRust, subnix, lib, system, devnetTools, ... }: {
      packages = rec {
        gex = self.inputs.cosmos.packages.${system}.gex;
        beaker = self.inputs.cosmos.packages.${system}.beaker;
        bech32cli = self.inputs.bech32cli.packages.${system}.default;
      };
    };
}
