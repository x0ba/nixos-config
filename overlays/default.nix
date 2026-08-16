{ inputs, ... }: {
  additions = final: _prev: import ../pkgs final.pkgs;

  modifications = final: prev: {
  };

  # Exposes the stable nixpkgs input as pkgs.stablePkgs.
  stable-packages = final: _prev: {
    stablePkgs = import inputs.nixpkgs {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}
