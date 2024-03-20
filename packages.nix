{self, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    system,
    pkgs,
    ...
  }: {
    packages = {
      up = pkgs.writeShellApplication {
        name = "up";
        text = ''
          nix flake lock --update-input networks --update-input cosmos --update-input composable-vm
          git add .
          git commit -m "up"
          git push
        '';
      };
    };
  };
}
