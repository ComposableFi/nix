{
  description = "Description for the project";
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://cosmos.cachix.org"
      "https://nixpkgs-update.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cosmos.cachix.org-1:T5U9yg6u2kM48qAOXHO/ayhO8IWFnv0LOhNcq0yKuR8="
      "nixpkgs-update.cachix.org-1:6y6Z2JdoL3APdu6/+Iy8eZX2ajf09e4EE9SnxSML1W8="
    ];
  };
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    process-compose-flake = {
      url = "github:Platonic-Systems/process-compose-flake";
    };
    process-compose = {
      url = "github:F1bonacc1/process-compose";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    cosmos = {
      url = "github:informalsystems/cosmos.nix/dz/38";
    };
    bech32cli = {
      url = "github:strangelove-ventures/bech32cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    composable-vm = {url = "github:ComposableFi/composable-vm";};
    networks = {url = "github:ComposableFi/networks";};

    eth-pos-devnet-src = {
      flake = false;
      url = "github:OffchainLabs/eth-pos-devnet";
    };
    ethereum = {url = "github:nix-community/ethereum.nix";};
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./args.nix
        ./devShells.nix
        ./formatter.nix
        ./packages.nix
        ./cosmos/centauri.nix
        ./cosmos/osmosis.nix
      ];
      systems = ["x86_64-linux"];
      perSystem = {
        config,
        self',
        inputs',
        ...
      }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.
        packages = {
          default = inputs'.nixpkgs.legacyPackages.figlet;
        };
      };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
      };
    };
}
