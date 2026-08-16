{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
  ];

  nixpkgs = {
    overlays = [
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
      inputs.self.overlays.stable-packages
    ];
    config = {
      allowUnfree = true;
    };
    hostPlatform = "aarch64-darwin";
  };

  # Determinate Nix already manages the Nix installation and daemon.
  # Letting nix-darwin take that over would fight /etc/nix/nix.conf.
  nix.enable = false;

  networking.hostName = "Daniels-MacBook-Pro";

  system.primaryUser = "daniel";

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
    casks = [
      "1password"
      "balenaetcher"
      "cursor"
      "discord"
      "fantastical"
      "ghostty"
      "google-chrome"
      "grok-bot"
      "imageoptim"
      "istat-menus"
      "karabiner-elements"
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
      "wispr-flow"

    ];

    brews = [
      "gnupg"
    ];
  };

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
