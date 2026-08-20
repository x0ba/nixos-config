{
  description = "daniel's nix config";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    herdr-jj-status = {
      url = "github:mroth/herdr-jj-status";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs-unstable,
      home-manager,
      nix-darwin,
      ...
    }@inputs:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs-unstable.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system: {
        home-manager = home-manager.packages.${system}.default;
      });
      formatter = forAllSystems (system: nixpkgs-unstable.legacyPackages.${system}.nixfmt-tree);

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
        in
        {
          # Cross-eval both hosts so `nix flake check` on either machine
          # catches home.nix and Darwin-module breaks.
          home-tp = pkgs.runCommand "check-home-tp" { } ''
            mkdir -p $out
            echo ${self.homeConfigurations.tp.config.home.username} > $out/ok
          '';
          darwin-mbp = pkgs.runCommand "check-darwin-mbp" { } ''
            mkdir -p $out
            echo ${self.darwinConfigurations.Daniels-MacBook-Pro.config.networking.hostName} > $out/ok
            echo ${self.darwinConfigurations.Daniels-MacBook-Pro.config.home-manager.users.daniel.home.username} >> $out/ok
          '';
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              nixfmt-tree
              nixfmt
              nil
              nh
            ];
            # Working tree, not the flake's store copy — nh needs to see local edits.
            shellHook = ''
              export NH_FLAKE="$PWD"
            '';
          };
        }
      );

      darwinConfigurations = {
        Daniels-MacBook-Pro = nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./darwin/configuration.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.daniel.imports = [
                ./home-manager/home.nix
                ./home-manager/darwin.nix
              ];
            }
          ];
        };
      };

      homeConfigurations =
        let
          mkPkgs =
            system:
            import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          tp = home-manager.lib.homeManagerConfiguration {
            pkgs = mkPkgs "x86_64-linux";
            extraSpecialArgs = { inherit inputs; };
            modules = [
              ./home-manager/home.nix
              ./home-manager/linux.nix
            ];
          };
        in
        {
          inherit tp;
          "daniel@tp" = tp;
        };
    };
}
