{self, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    system,
    pkgs,
    ...
  }: {
    process-compose.cosmos-devnet = {
      settings = import ./cosmos-devnet.nix {
        inherit (self') packages;
        inherit (pkgs) networksLib;
        log_directory = pkgs.networksLib.networks.devnet.directories.DEVNET_LOG_DIRECTORY;
      };
    };
  };
}
