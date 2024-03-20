{ networksLib
, packages
,
}: {
  log_level = "trace";
  log_location = "${networksLib.networks.devnet.directories.DEVNET_LOG_DIRECTORY}/cosmos-devnet.log";

  processes = {
    centauri-init = {
      command = packages.centauri-init;
      log_location = "${networksLib.networks.devnet.directories.DEVNET_LOG_DIRECTORY}/centauri-init.log";
      availability = { restart = "no"; };
    };
    centauri-start = {
      command = packages.centauri-start;
      depends_on."centauri-init".condition = "process_completed_successfully";
      log_location = "${networksLib.networks.devnet.directories.DEVNET_LOG_DIRECTORY}/centauri-start.log";
      readiness_probe.http_get = {
        host = "127.0.0.1";
        port = networksLib.networks.pica.devnet.CONSENSUS_RPC_PORT;
      };

      availability = { restart = "always"; };
    };
  };
}
