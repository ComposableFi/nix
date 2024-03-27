{self, ...}: {
  perSystem = {
    config,
    self',
    inputs',
    system,
    pkgs,
    runtimeInputs,
    ...
  }: {
    packages = let
      networks = pkgs.networksLib.networks;
      sh = pkgs.networksLib.sh;
    in {
      mantis-simulate = pkgs.writeShellApplication {
        name = "mantis-simulate";
        runtimeInputs = runtimeInputs;
        text = ''
          ${sh.export networks.devnet.directories}
          ${sh.export networks.pica.devnet}
          ${sh.export networks.devnet.mnemonics}
          ${builtins.readFile ./cosmos_sdk.sh}
          RPC_CENTAURI="http://0.0.0.0:$CONSENSUS_RPC_PORT"
          GRPC_CENTAURI="http://0.0.0.0:$GRPCPORT"
          WALLET="$ALICE"
          CVM_CONTRACT=$(cat "$CHAIN_DATA/CVM_OUTPOST_CONTRACT_ADDRESS")
          ORDER_CONTRACT=$(cat "$CHAIN_DATA/MANTIS_ORDER_CONTRACT_ADDRESS")
          ${builtins.readFile ./mantis-simulate.sh}
        '';
      };
    };
  };
}
