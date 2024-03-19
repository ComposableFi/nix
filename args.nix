{ self, ... }: {
  perSystem = { config, self', inputs', system, pkgs, ... }: {
    _module.args = {
      runtimeInputs = with pkgs; [
            getoptions
            jq
            dasel
            centauri
          ];
      pkgs = import self.inputs.nixpkgs {
        inherit system;
        overlays = with self.inputs; [
          process-compose.overlays.default
          networks.overlays.default
          cosmos.overlays.default
          # cosmos.overlays.cosmosNixPackages
        ];
      };
    };
  };
}
