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
      };
    };
  };
}
