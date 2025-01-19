{ self, inputs, ... }: {
  flake = {
    nixosConfigurations.postgres = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.base
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
