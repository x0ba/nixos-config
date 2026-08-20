{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.programs.herdr;
  pluginId = "mroth.jj-status";
  src = inputs.herdr-jj-status;
  herdr-jj-status = pkgs.stdenvNoCC.mkDerivation {
    pname = "herdr-jj-status";
    inherit (builtins.fromTOML (builtins.readFile "${src}/herdr-plugin.toml")) version;
    inherit src;

    dontConfigure = true;
    dontBuild = true;

    # herdr runs manifest commands as argv against the *server* PATH, which
    # may not include the home-manager profile. Pin interpreters and tools.
    env.runtimePath = lib.makeBinPath [
      pkgs.bash
      pkgs.jujutsu
      pkgs.jq
      pkgs.gnugrep
      pkgs.coreutils
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -R . "$out/"
      substituteInPlace "$out/herdr-plugin.toml" \
        --replace-fail '"bash"' '"${lib.getExe pkgs.bash}"'
      substituteInPlace "$out/bin/refresh.sh" \
        --replace-fail 'set -u' "export PATH=$runtimePath"$'\n'"set -u"
      runHook postInstall
    '';

    meta = {
      description = "herdr plugin: Jujutsu bookmark and status in the spaces sidebar";
      homepage = "https://github.com/mroth/herdr-jj-status";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  };

  # Stable path so herdr's plugins.json survives store-path changes.
  pluginRoot = "${config.xdg.configHome}/herdr/plugins/jj-status";
  herdrBin = if cfg.package == null then "herdr" else lib.getExe cfg.package;
in
{
  config = lib.mkIf cfg.enable {
    xdg.configFile."herdr/plugins/jj-status".source = herdr-jj-status;

    home.activation.herdrJjStatus = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      have=$(${lib.escapeShellArg herdrBin} plugin list --plugin ${pluginId} --json 2>/dev/null \
        | ${lib.getExe pkgs.jq} -r '.result.plugins[0].plugin_root // empty') || have=""
      if [ "$have" != ${lib.escapeShellArg pluginRoot} ]; then
        if [ -n "$have" ]; then
          run ${lib.escapeShellArg herdrBin} plugin unlink ${pluginId} 2>/dev/null \
            || run ${lib.escapeShellArg herdrBin} plugin uninstall ${pluginId} 2>/dev/null \
            || true
        fi
        run ${lib.escapeShellArg herdrBin} plugin link ${lib.escapeShellArg pluginRoot}
      fi
    '';
  };
}
