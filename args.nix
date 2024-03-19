{ self, ... }: {
  perSystem = { config, self', inputs', system, pkgs, ... }: {
    _module.args.pkgs = import self.inputs.nixpkgs {
      inherit system;
      overlays = with self.inputs; [
        process-compose.overlays.default
        networks.overlays.default
      ];
    };
  };
}
