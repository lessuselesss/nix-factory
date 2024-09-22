{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixos-generators, nixpkgs, ... }@inputs: {
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

    nixosConfigurations.postgres = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ./postgresql.nix self.nixosModules.vm ];
      specialArgs = {
        inherit inputs;
        hostName = "postgres";
        diskSize = "16384";
      };
    };

    devShells.aarch64-darwin.default =
      let pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      in pkgs.mkShell {
        packages = with pkgs; [ inputs.nil.packages.${system}.nil ];
      };

    devShells.x86_64-linux.default =
      let pkgs = nixpkgs.legacyPackages.x86_64-linux;
      in pkgs.mkShell {
        packages = with pkgs; [ inputs.nil.packages.${system}.nil ];
      };

  };
}
