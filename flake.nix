{
  outputs = inputs@{ self, flake-parts, nixos-generators, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      flake = {

        # VMs
        nixosModules.generators = { config, ... }: {
          imports = [ nixos-generators.nixosModules.all-formats ];
          nixpkgs.hostPlatform = "aarch64-linux";
        };

        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
          modules = [
            ./configurations/base.nix
            ./configurations/qemu.nix
            self.nixosModules.generators
          ];
          specialArgs = {
            inherit inputs;
            hostName = "nixos";
            diskSize = "16384";
          };
        };

        nixosConfigurations.postgres = nixpkgs.lib.nixosSystem {
          modules = [
            ./configurations/base.nix
            ./configurations/qemu.nix
            ./configurations/postgres/postgres.nix
            self.nixosModules.generators
          ];
          specialArgs = {
            inherit inputs;
            hostName = "postgres";
            diskSize = "16384";
          };
        };

        nixosConfigurations.pg_master = nixpkgs.lib.nixosSystem {
          modules = [
            ./configurations/base.nix
            ./configurations/qemu.nix
            ./configurations/postgres/master.nix
            self.nixosModules.generators
          ];
          specialArgs = {
            inherit inputs;
            hostName = "master";
            diskSize = "16384";
          };
        };

        nixosConfigurations.pg_slave = nixpkgs.lib.nixosSystem {
          modules = [
            ./configurations/base.nix
            ./configurations/qemu.nix
            ./configurations/postgres/slave.nix
            self.nixosModules.generators
          ];
          specialArgs = {
            inherit inputs;
            hostName = "slave";
            diskSize = "16384";
          };
        };

        nixosConfigurations.k3s_raspberry_master_sd = nixpkgs.lib.nixosSystem {
          modules = [
            ./configurations/base.nix
            ./configurations/k3s-raspberrypi/k3s-master.nix
            self.nixosModules.generators
          ];
          specialArgs = {
            inherit inputs;
            hostName = "master";
          };
        };

        nixosConfigurations.k3s_raspberry_master = nixpkgs.lib.nixosSystem {
          modules = [
            ./configurations/base.nix
            ./configurations/k3s-raspberrypi/k3s-master.nix
            ./configurations/raspberrypi-rebuild.nix
          ];
          specialArgs = {
            inherit inputs;
            hostName = "master";
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
