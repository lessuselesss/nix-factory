{
  outputs = inputs@{ self, flake-parts, nixos-generators, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];
      imports = [ ./configurations/postgres/flake.nix ];
      flake = {
        nixosModules.base = { config, ... }: {
          imports = [
            ./common/base.nix
            ./common/qemu.nix
            nixos-generators.nixosModules.all-formats
          ];
          nixpkgs.hostPlatform = "aarch64-linux";
        };

        nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
          modules = [ self.nixosModules.base ];
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
