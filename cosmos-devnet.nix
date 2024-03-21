{
  networksLib,
  packages,
  log_directory,
}: {
  log_level = "trace";
  log_location = "${log_directory}/cosmos-devnet.log";

  processes = {
    centauri-init = {
      command = packages.centauri-init;
      log_location = "${log_directory}/centauri-init.log";
      availability = {restart = "on_failure";};
    };
    centauri-start = {
      command = packages.centauri-start;
      depends_on."centauri-init".condition = "process_completed_successfully";
      log_location = "${log_directory}/centauri-start.log";
      readiness_probe.http_get = {
        host = "127.0.0.1";
        port = networksLib.networks.pica.devnet.CONSENSUS_RPC_PORT;
      };
      availability = {restart = "always";};
    };
    osmosis-init = {
      command = packages.osmosis-init;
      log_location = "${log_directory}/osmosis-init.log";
      availability = {restart = "on_failure";};
    };
    osmosis-start = {
      command = packages.osmosis-start;
      depends_on."osmosis-init".condition = "process_completed_successfully";
      log_location = "${log_directory}/osmosis-start.log";
      readiness_probe.http_get = {
        host = "127.0.0.1";
        port = networksLib.networks.osmosis.devnet.CONSENSUS_RPC_PORT;
      };
      availability = {restart = "always";};
    };
    osmosis-centauri-init = {
      command = packages.osmosis-centauri-init;
      log_location = "${log_directory}/osmosis-centauri-init.log";
      availability = {restart = "on_failure";};
      depends_on = {
        "osmosis-start".condition = "process_healthy";
        "centauri-start".condition = "process_healthy";
      };
      namespace = "bridge";
    };
    osmosis-centauri-start = {
      command = packages.osmosis-centauri-start;
      log_location = "${log_directory}/osmosis-centauri-start.log";
      availability = {restart = "always";};
      depends_on = {
        "osmosis-centauri-init".condition = "process_completed_successfully";
      };
      namespace = "bridge";
    };
  };
}
