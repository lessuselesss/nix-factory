{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixos-generators, nixpkgs }@inputs: {
    nixosModules.vm = { config, ... }: {
      imports = [ nixos-generators.nixosModules.all-formats ];
      nixpkgs.hostPlatform = "aarch64-linux";
    };

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix self.nixosModules.vm ];
      specialArgs = {
        inherit inputs;
        hostName = "nixos";
        diskSize = "16384";
      };
    };
  };
}
