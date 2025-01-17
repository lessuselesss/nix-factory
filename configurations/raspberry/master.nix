{ config, lib, pkgs, specialArgs, ... }:

{
  networking = {
    interfaces = {
      end0.ipv4.addresses = [{
        address = "192.168.1.65";
        prefixLength = 24;
      }];
    };
    defaultGateway = "192.168.1.1";
    nameservers = ["1.1.1.1", "1.0.0.1"]
  };
}
