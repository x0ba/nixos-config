{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.herdr.autoExecOnSsh;
  herdr = lib.getExe pkgs.herdr;
in
{
  options.my.herdr.autoExecOnSsh = lib.mkEnableOption "exec herdr on interactive SSH";

  config = lib.mkIf cfg {
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
  };
}
