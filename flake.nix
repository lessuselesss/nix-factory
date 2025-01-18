{
  outputs = inputs@{ self, flake-parts, nixos-generators, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [
        ./configurations/postgres/flake.nix
        ./configurations/k3s-raspberrypi/flake.nix
      ];
      flake = {
        nixosModules.generators = { config, ... }: {
          imports = [ nixos-generators.nixosModules.all-formats ];
          nixpkgs.hostPlatform = "aarch64-linux";
        };

        nixosModules.base = { lib, pkgs, specialArgs, ... }: {
          imports = [ ./common/base.nix ];
        };

        nixosModules.qemu = { ... }: { imports = [ ./common/qemu.nix ]; };

        nixosModules.raspberrypi-rebuild = { lib, modulesPath, ... }: {
          imports = [ ./common/raspberrypi-rebuild.nix ];
        };

        nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.base
            self.nixosModules.qemu
            self.nixosModules.generators
          ];
          specialArgs = {
            inherit inputs;
            hostName = "nixos";
            diskSize = "16384";
          };
        };
      };

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            inputs.nil.packages.${system}.nil
            nixos-rebuild
          ];
        };
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
