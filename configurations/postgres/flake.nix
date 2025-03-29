{ self, inputs, ... }: {
  flake = {
    darwinConfigurations.postgres = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.base
        ./postgres.nix
      ];
      specialArgs = {
        inherit inputs;
        hostName = "postgres";
      };
    };

    darwinConfigurations.pg_master = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.base
        ./master.nix
      ];
      specialArgs = {
        inherit inputs;
        hostName = "master";
      };
    };

    darwinConfigurations.pg_slave = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        self.nixosModules.base
        ./slave.nix
      ];
      specialArgs = {
        inherit inputs;
        hostName = "slave";
      };
    };
  };
}
