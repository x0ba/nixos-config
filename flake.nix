{
  description = "daniel's nix config";

  inputs = {
    # Default pin; stable is exposed as pkgs.stablePkgs via overlays/default.nix.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # These repos are not flakes.
    theme-bobthefish.url = "github:oh-my-fish/theme-bobthefish/e3b4d4eafc23516e35f162686f08a42edf844e40";
    theme-bobthefish.flake = false;
    fish-fzf.url = "github:jethrokuan/fzf/24f4739fc1dffafcc0da3ccfbbd14d9c7d31827a";
    fish-fzf.flake = false;
    fish-foreign-env.url = "github:oh-my-fish/plugin-foreign-env/dddd9213272a0ab848d474d0cbde12ad034e65bc";
    fish-foreign-env.flake = false;
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
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs-unstable.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        (import ./pkgs nixpkgs-unstable.legacyPackages.${system})
        // {
          home-manager = home-manager.packages.${system}.default;
        }
      );
      formatter = forAllSystems (system: nixpkgs-unstable.legacyPackages.${system}.nixfmt-tree);

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            packages = [
              pkgs.nixfmt-tree
              pkgs.nil
            ];
          };
        }
      );

      overlays = import ./overlays { inherit inputs; };
      nixosModules = import ./modules/nixos;
      darwinModules = import ./modules/darwin;
      homeManagerModules = import ./modules/home-manager;

      # darwin-rebuild switch --flake .#Daniels-MacBook-Pro
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
              home-manager.users.daniel = import ./home-manager/home.nix;
            }
          ];
        };
      };

      #   home-manager switch --flake .#daniel@tp
      homeConfigurations =
        let
          mkPkgs =
            system:
            import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
              overlays = builtins.attrValues (import ./overlays { inherit inputs; });
            };
          tp = home-manager.lib.homeManagerConfiguration {
            pkgs = mkPkgs "x86_64-linux";
            extraSpecialArgs = { inherit inputs; };
            modules = [
              ./home-manager/home.nix
              ./home-manager/omarchy.nix
            ];
          };
        in
        {
          inherit tp;
          "daniel@tp" = tp;
        };
    };
}
