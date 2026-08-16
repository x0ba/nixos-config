{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let

  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
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

    cat = "bat";
    find = "fd";
    grep = "rg";
    du = "dust";
    df = "duf";
    ps = "procs";
    tree = "eza --tree";
  };
in
{
  imports = [
  ];

  home = {
    username = "daniel";
    homeDirectory = if isDarwin then "/Users/daniel" else "/home/daniel";

    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };

    # Most packages come from per-project flakes, so this list stays small.
    packages = with pkgs; [
      _1password-cli
      dust
      duf
      fzf
      gh
      htop
      jq
      neovim
      procs
      herdr
      hunk

      codex
      opencode
    ];
  };

  programs.home-manager.enable = true;

  programs.bat.enable = true;

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    extraOptions = [ "--group-directories-first" ];
    enableNushellIntegration = true;
  };

  programs.fd.enable = true;

  programs.ripgrep.enable = true;

  # --cmd cd makes `cd` use zoxide's smart jump.
  programs.zoxide = {
    enable = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    enableJujutsuIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Daniel Xu";
      user.email = "hi@danielx.me";
      push.default = "tracking";
      init.defaultBranch = "main";
    };
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = config.programs.git.settings.user.name;
        email = config.programs.git.settings.user.email;
      };
      ui.default-command = "status";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.ghostty = lib.mkIf isDarwin {
    enable = true;
    # Homebrew cask owns the app; this module only writes config + shell hooks.
    package = null;
    systemd.enable = false;
    enableFishIntegration = true;
    enableZshIntegration = true;
    enableBashIntegration = false;
    settings = {
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
  };

  programs.fish = {
    enable = true;
    shellAliases = shellAliases;
    functions.fish_greeting = "";
    shellInit = lib.optionalString isDarwin ''
      if test -d /opt/homebrew
        eval (/opt/homebrew/bin/brew shellenv fish)
      end
    '';
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
    shellAliases = shellAliases;
    settings.show_banner = false;
  };

  home.stateVersion = "25.11";
}
