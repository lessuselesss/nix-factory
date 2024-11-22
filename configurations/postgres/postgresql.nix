{ config, lib, pkgs, specialArgs, ... }:

{
  # https://search.nixos.org/options?query=services.postgresql
  services.postgresql = {
    enable = true;
    # ensureDatabases = [ "nixos" ];
    # ensureUsers = [{
    #   name = "nixos";
    #   ensureDBOwnership = true;
    #   ensureClauses = {
    #     login = true;
    #     replication = true;
    #   };
    # }];
    enableTCPIP = true;
    package = pkgs.postgresql_16;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  host           auth-method
      local all       all                    trust
      # ipv4
      host  all       all     127.0.0.1/32   trust
      host  nixos     nixos   0.0.0.0/0      md5
      # ipv6
      host all        all     ::1/128        trust
    '';
    initialScript = pkgs.writeText "backend-initScript" ''
      CREATE ROLE nixos WITH LOGIN PASSWORD 'nixos' REPLICATION;
      CREATE DATABASE nixos;
      GRANT ALL PRIVILEGES ON DATABASE nixos TO nixos;
    '';
  };

  networking.firewall.allowedTCPPorts = [ 5432 ];
}
