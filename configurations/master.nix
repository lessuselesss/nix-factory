{ config, lib, pkgs, specialArgs, ... }:

{
  # https://search.nixos.org/options?query=services.postgresql
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_16;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database    DBuser  host           auth-method
      local all         all                       trust
      # ipv4
      host  all         all     127.0.0.1/32      trust
      host  nixos       nixos   0.0.0.0/0         md5
      host  replication nixos   192.168.205.11/32 trust #normally would be scram-sha-256
      # ipv6
      host  all         all     ::1/128           trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE nixos WITH LOGIN PASSWORD 'nixos' REPLICATION;
      CREATE DATABASE nixos;
      GRANT ALL PRIVILEGES ON DATABASE nixos TO nixos;
      GRANT EXECUTE ON function pg_catalog.pg_ls_dir(text,boolean,boolean) TO nixos;
      GRANT EXECUTE ON function pg_catalog.pg_stat_file(text,boolean) TO nixos;
      GRANT EXECUTE ON function pg_catalog.pg_read_binary_file(text) TO nixos;
      GRANT EXECUTE ON function pg_catalog.pg_read_binary_file(text,bigint,bigint,boolean) TO nixos;
      SELECT * FROM pg_create_physical_replication_slot('slave');
    '';
    settings = {
      wal_level = "replica";
      wal_log_hints = "on";
      max_wal_senders = 5;
      max_replication_slots = 5;
      logging_collector = true;
    };
  };

  networking = {
    interfaces = {
      enp0s1.ipv4.addresses = [{
        address = "192.168.205.10";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.205.1";
  };
  networking.firewall.allowedTCPPorts = [ 5432 ];
}
