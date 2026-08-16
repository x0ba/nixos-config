{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let

  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
  shellAliases = {
    ga = "git add";
    gc = "git commit";
    gco = "git checkout";
    gcp = "git cherry-pick";
    gdiff = "git diff";
    gl = "git prettylog";
    gp = "git push";
    gs = "git status";
    gt = "git tag";

    jd = "jj desc";
    jf = "jj git fetch";
    jn = "jj new";
    jp = "jj git push";
    js = "jj st";
  };
in
{
  imports = [
  ];

  home = {
    username = "daniel";
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/daniel" else "/home/daniel";

    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
    ];

    # Most packages come from per-project flakes, so this list stays small.
    packages = [
      pkgs._1password-cli
      pkgs.bat
      pkgs.chezmoi
      pkgs.eza
      pkgs.fd
      pkgs.fzf
      pkgs.gh
      pkgs.htop
      pkgs.jq
      pkgs.ripgrep
      pkgs.tree

      pkgs.nodejs
      pkgs.pnpm
      pkgs.bun

      pkgs.codex
      pkgs.opencode
    ];
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings = {
      user.name = "Daniel Xu";
      user.email = "hi@danielx.me";
      push.default = "tracking";
      init.defaultBranch = "main";
    };
  };

  programs.jujutsu.enable = true;

  programs.direnv.enable = true;

  programs.ghostty = {
    enable = true;
    # Homebrew cask owns the app; this module only writes config + shell hooks.
    package = null;
    enableFishIntegration = true;
    enableZshIntegration = false;
    enableBashIntegration = false;
    settings = {
      # cursor, sudo, title, ssh-env, ssh-terminfo, path
      shell-integration-features = true;
    };
  };

  programs.zsh = {
    enable = true;
    # Lock the current location; HM will default to XDG after stateVersion 26.05.
    dotDir = config.home.homeDirectory;
    shellAliases = shellAliases;
    prezto = {
      enable = true;
      # HM defaults this to true; unset in the old ~/.zpreztorc meant insensitive.
      caseSensitive = false;
      color = true;
      pmodules = [
        "environment"
        "terminal"
        "editor"
        "history"
        "directory"
        "spectrum"
        "utility"
        "completion"
        "history-substring-search"
        "prompt"
      ];
      editor.keymap = "emacs";
      prompt.theme = "sorin";
    };
    envExtra = ''
      [[ -s "$HOME/.vite-plus/env" ]] && . "$HOME/.vite-plus/env"
    '';
    profileExtra = lib.optionalString isDarwin ''
      if [[ -d /opt/homebrew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv zsh)"
      fi
    '';
    initContent = ''
      if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
      fi
    '';
  };

  programs.fish = {
    enable = true;
    shellAliases = shellAliases;
    interactiveShellInit = lib.strings.concatStrings (
      lib.strings.intersperse "\n" ([
        "source ${inputs.theme-bobthefish}/functions/fish_prompt.fish"
        "source ${inputs.theme-bobthefish}/functions/fish_right_prompt.fish"
        "source ${inputs.theme-bobthefish}/functions/fish_title.fish"
        (builtins.readFile ./config.fish)
        "set -g SHELL ${pkgs.fish}/bin/fish"
      ])
    );

    plugins =
      map
        (n: {
          name = n;
          src = inputs.${n};
        })
        [
          "fish-fzf"
          "fish-foreign-env"
          "theme-bobthefish"
        ];
  };

  programs.atuin.enable = true;

  programs.nushell = {
    enable = true;
  };

  home.stateVersion = "25.11";
}
