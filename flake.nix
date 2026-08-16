{
  description = "daniel's nix config";

  inputs = {
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
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
          # Forces eval of the Linux host so Darwin `nix flake check` catches home.nix breaks.
          home-tp = pkgs.runCommand "check-home-tp" { } ''
            mkdir -p $out
            echo ${self.homeConfigurations.tp.config.home.username} > $out/ok
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
              gnumake
            ];
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
