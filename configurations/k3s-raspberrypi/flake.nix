# It seems like building an sd img and rebuilding a live system requires completely different configs, for root filesystems, boot process, etc. I was unable to rebuild a live system with the same configuration as I built img (due to nixosGenerators module) and vice versa. Therefore, create .img with nixosConfigurations ending with _sd suffix, and rebuild already running system without suffix.
{ self, inputs, ... }: {
  flake = {
        nixosConfigurations.k3s_raspberry_master_sd = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.base
            self.nixosModules.generators
            ./k3s-master.nix
          ];
          specialArgs = {
            inherit inputs;
            hostName = "k3s-master";
          };
        };

        nixosConfigurations.k3s_raspberry_master = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.base
            self.nixosModules.raspberrypi-rebuild
            ./k3s-master.nix
          ];
          specialArgs = {
            inherit inputs;
            hostName = "k3s-master";
          };
        };

  };
}
