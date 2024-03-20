{self, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    system,
    pkgs,
    ...
  }: {
    _module.args = {
      runtimeInputs = with pkgs; [
        bun
        centauri
        cw-cvm-executor
        cw-cvm-outpost
        cw-mantis-order
        dasel
        getoptions
        gex
        grpcurl
        jq
        nix-tree
        osmosis
      ];
      pkgs = import self.inputs.nixpkgs {
        inherit system;
        overlays = with self.inputs; [
          process-compose.overlays.default
          networks.overlays.default
          cosmos.overlays.default
          # cosmos.overlays.cosmosNixPackages
          (final: prev: {
            cw-cvm-executor = self.inputs.composable-vm.packages."${system}".cw-cvm-executor;
            cw-cvm-outpost = self.inputs.composable-vm.packages."${system}".cw-cvm-outpost;
            cw-mantis-order = self.inputs.composable-vm.packages."${system}".cw-mantis-order;
          })
        ];
      };
    };
  };
}
