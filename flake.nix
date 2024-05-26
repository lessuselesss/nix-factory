{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixos-generators, disko, nixpkgs }@inputs: {
    nixosModules.vm = { config, ... }: {
      imports = [ nixos-generators.nixosModules.all-formats ];

      nixpkgs.hostPlatform = "aarch64-linux";

    };

    # the evaluated machine
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix self.nixosModules.vm ];
      specialArgs = {
        inherit inputs;
        diskSize = "20480";
      };
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ./hardware-configuration.nix ];
      specialArgs = { inherit inputs; };
    };

    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
        ./configuration.nix
        ./hardware-configuration.nix
      ];
      specialArgs = { inherit inputs; };
    };
  };
}
