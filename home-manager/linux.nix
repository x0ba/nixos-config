{ lib, pkgs, ... }:
let
  herdr = lib.getExe pkgs.herdr;
in
{
  targets.genericLinux.enable = true;

  services.ssh-agent.enable = true;

  # Interactive SSH only. HERDR_ENV is set inside panes, so this does not nest.
  programs.fish.interactiveShellInit = lib.mkBefore ''
    if set -q SSH_CONNECTION; and not set -q HERDR_ENV
      exec ${herdr}
    end
  '';

  programs.zsh.initExtraFirst = lib.mkBefore ''
    if [[ -n "$SSH_CONNECTION" && -z "$HERDR_ENV" ]]; then
      exec ${herdr}
    fi
  '';
}
