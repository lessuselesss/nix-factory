{ config, lib, pkgs, specialArgs, ... }:

{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  security.sudo.wheelNeedsPassword = false;
  services.openssh.enable = true;
  services.qemuGuest.enable = true;

  networking.hostName = specialArgs.hostName;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  time.timeZone = "Europe/Warsaw";

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword =
      "$y$j9T$n3O9OwpZhBIdE.EVjrv.z.$aXdFNEAcQOWG3sj9yTm90pUh2bMP5V5wo6uXDDLIhO8";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAG0Q9SO1UHD1lFrUwaZW3S74jHwLuu26WKgUcJqNHNG"
    ];
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  system.stateVersion = "23.11";
}
