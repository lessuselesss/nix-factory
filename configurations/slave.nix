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
      # ipv6
      host  all         all     ::1/128           trust
    '';
    settings = {
      wal_level = "replica";
      wal_log_hints = "on";
      max_wal_senders = 5;
      max_replication_slots = 5;
      logging_collector = true;
    };
  };

  systemd.services.startReplication = {
    script = ''
      if [[ -z $(grep 'primary_conninfo' /var/lib/postgresql/16/postgresql.auto.conf) && -z $(grep 'primary_slot_name' /var/lib/postgresql/16/postgresql.auto.conf) ]]; then
        systemctl stop postgresql
        rm -rf /var/lib/postgresql/16
        /run/wrappers/bin/su - postgres -c 'pg_basebackup -h 192.168.205.10 -U nixos -S slave -R -D /var/lib/postgresql/16 -X stream -P'
        /run/current-system/sw/bin/sed -i "s/primary_conninfo = '/primary_conninfo = 'application_name=slave /" /var/lib/postgresql/16/postgresql.auto.conf
        systemctl start postgresql
      fi
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "postgresql.service" ];
  };

  networking = {
    interfaces = {
      enp0s1.ipv4.addresses = [{
        address = "192.168.205.11";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.205.1";
  };
  networking.firewall.allowedTCPPorts = [ 5432 ];
}

# To kick off replication:
## Make sure cluster is fresh
## stop postgresql sevice with systemctl
## delete /var/lib/postgresql/16 directory
## copy master via pg_basebackup -h 192.168.205.10 -U nixos -S slave -R -D /var/lib/postgresql/slave -X stream -P (do not create replication slot, since it's not idempotent on master in case I want to recreate slave)
## add application_name to primary_conninfo
## start postgresql with systemd

# Promoting slave to master:
## stop primary
## promote slave with psql -c "SELECT pg_promote();"
## you can now kick off replication the other way around

# other useful nix-postgres specific packages:
## https://sr.ht/~bwolf/patroni.nix/
## https://sr.ht/~bwolf/hapsql.nix/
