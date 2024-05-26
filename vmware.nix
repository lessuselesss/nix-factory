{ config, nixos-generators, ... }: {

  imports = [ nixos-generators.nixosModules.all-formats ];

  nixpkgs.hostPlatform = "aarch64-linux";

  # customize an existing format
  # formatConfigs.vmware = { config, ... }: { services.openssh.enable = true; };

  # define a new format
  # formatConfigs.my-custom-format = { config, modulesPath, ... }: {
  #   imports =
  #     [ "${toString modulesPath}/installer/cd-dvd/installation-cd-base.nix" ];
  #   formatAttr = "isoImage";
  #   fileExtension = ".iso";
  #   networking.wireless.networks = {
  #     # ...
  #   };
  # };
}
