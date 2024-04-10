{
  networksLib,
  packages,
  log_directory,
}: {
  log_level = "debug";
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
      readiness_probe = {
        http_get = {
          host = "0.0.0.0";
          port = networksLib.networks.osmosis-centauri.devnet.REST_PORT;
          path = "/version";
        };
      };
      depends_on = {
        "osmosis-centauri-init".condition = "process_completed_successfully";
      };
      namespace = "bridge";
    };
    osmosis-cvm-init = {
      command = packages.osmosis-cvm-init;
      log_location = "${log_directory}/osmosis-cvm-init.log";
      availability = {restart = "on_failure";};
      depends_on = {
        "osmosis-centauri-init".condition = "process_completed_successfully";
      };
      namespace = "cvm";
    };

    centauri-cvm-init = {
      command = packages.centauri-cvm-init;
      log_location = "${log_directory}/centauri-cvm-init.log";
      availability = {restart = "on_failure";};
      depends_on = {
        "osmosis-centauri-init".condition = "process_completed_successfully";
      };
      namespace = "cvm";
    };

    cvm-config = {
      command = packages.cvm-config;
      log_location = "${log_directory}/cvm-config.log";
      availability = {restart = "on_failure";};
      depends_on = {
        "centauri-cvm-init".condition = "process_completed_successfully";
        "osmosis-cvm-init".condition = "process_completed_successfully";
      };
      namespace = "cvm";
    };
    centauri-cvm-config = {
      command = packages.centauri-cvm-config;
      log_location = "${log_directory}/centauri-cvm-config.log";
      availability = {restart = "on_failure";};
      depends_on = {
        "cvm-config".condition = "process_completed_successfully";
      };
      namespace = "cvm";
    };
    osmosis-cvm-config = {
      command = packages.osmosis-cvm-config;
      log_location = "${log_directory}/osmosis-cvm-config.log";
      availability = {restart = "on_failure";};
      depends_on = {
        "cvm-config".condition = "process_completed_successfully";
      };
      namespace = "cvm";
    };

    osmosis-to-centauri-transfer = {
      command = packages.osmosis-to-centauri-transfer;
      log_location = "${log_directory}/osmosis-to-centauri-transfer.log";
      availability = {restart = "on_failure";};
      depends_on = {
        "osmosis-centauri-start".condition = "process_healthy";
      };
      namespace = "app";
    };

    centauri-to-osmosis-transfer = {
      command = packages.centauri-to-osmosis-transfer;
      log_location = "${log_directory}/centauri-to-osmosis-transfer.log";
      availability = {restart = "on_failure";};
      depends_on = {
        "osmosis-centauri-start".condition = "process_healthy";
      };
      namespace = "app";
    };

    mantis-order-simulate = {
      command = packages.mantis-order-simulate;
      log_location = "${log_directory}/mantis-order-simulate.log";
      availability = {restart = "on_failure";};
      depends_on = {
        "centauri-to-osmosis-transfer".condition = "process_completed_successfully";
        "osmosis-to-centauri-transfer".condition = "process_completed_successfully";
      };
      namespace = "app";
    };
  };
}
