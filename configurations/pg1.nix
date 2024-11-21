{ config, lib, pkgs, specialArgs, ... }:

{
  networking = {
    interfaces = {
      enp0s1.ipv4.addresses = [{
        address = "192.168.205.5";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.205.1";
  };
}
