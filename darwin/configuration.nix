{
  inputs,
  pkgs,
  ...
}:
{
  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = "aarch64-darwin";
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  # Determinate Nix already manages the Nix installation and daemon.
  # Letting nix-darwin take that over would fight /etc/nix/nix.conf.
  nix.enable = false;

  networking.hostName = "Daniels-MacBook-Pro";

  system.primaryUser = "daniel";

  system.defaults = {
    NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = true;
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      show-recents = false;
    };
  };

  # nix-darwin only writes UserShell for users listed here.
  users.knownUsers = [ "daniel" ];
  users.users.daniel = {
    name = "daniel";
    uid = 501;
    home = "/Users/daniel";
    shell = pkgs.fish;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    casks = [
      "1password"
      "adobe-creative-cloud"
      "balenaetcher"
      "cursor"
      "discord"
      "notion"
      "notion-calendar"
      "ollama-app"
      "fuse-t"
      "ghostty"
      "google-chrome"
      "granola"
      "grok-bot"
      "imageoptim"
      "istat-menus"
      "karabiner-elements"
      "intellij-idea"
      "datagrip"
      # using the raycast beta currently, will switch back
      # once the beta transitions over to stable
      # "raycast"
      "orbstack"
      "rectangle"
      "screenflow"
      "shottr"
      "slack"
      "spotify"
      "tailscale-app"
      "veracrypt-fuse-t"
      "wispr-flow"
    ];
  };

  fonts.packages = [
    # nixpkgs rebuilds this with gftools/nanoemoji; that FOD hash is currently broken.
    (pkgs.jetbrains-mono.overrideAttrs {
      nativeBuildInputs = [ ];
      dontBuild = true;
    })
  ];

  programs.fish.enable = true;
  programs.zsh.enable = true;

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    fish
  ];

  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  system.stateVersion = 6;
}
