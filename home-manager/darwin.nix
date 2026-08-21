{ pkgs, ... }:
{
  home.homeDirectory = "/Users/daniel";

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };

  programs.ghostty = {
    enable = true;
    # Homebrew cask owns the app; this module only writes config + shell hooks.
    package = null;
    systemd.enable = false;
    enableFishIntegration = true;
    enableZshIntegration = true;
    enableBashIntegration = false;
    settings = {
      shell-integration-features = true;
      theme = "vesper";
      font-family = "Fira Code";
    };
  };

  programs.zsh.profileExtra = ''
    if [[ -d /opt/homebrew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv zsh)"
    fi
  '';

  programs.fish.shellInit = ''
    if test -d /opt/homebrew
      eval (/opt/homebrew/bin/brew shellenv fish)
    end
  '';
}
