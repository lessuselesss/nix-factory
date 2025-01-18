{ self, inputs, ... }: {
  flake = {
    nixosConfigurations.postgres = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.base
        self.nixosModules.qemu
        self.nixosModules.generators
        ./postgres.nix
      ];
      specialArgs = {
        inherit inputs;
        hostName = "postgres";
        diskSize = "16384";
      };
    };

    nixosConfigurations.pg_master = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.base
        self.nixosModules.qemu
        self.nixosModules.generators
        ./master.nix
      ];
      specialArgs = {
        inherit inputs;
        hostName = "master";
        diskSize = "16384";
      };
    };

    nixosConfigurations.pg_slave = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.base
        self.nixosModules.qemu
        self.nixosModules.generators
        ./slave.nix
      ];
      specialArgs = {
        inherit inputs;
        hostName = "slave";
        diskSize = "16384";
      };
    };
  };
}
