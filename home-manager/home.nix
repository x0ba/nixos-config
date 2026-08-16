{
  config,
  pkgs,
  ...
}:
let
  signingKey = "8BE6AC395444462A";

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
    ../modules/home-manager
  ];

  home = {
    username = "daniel";

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

    file.".config/herdr/config.toml".text = ''
      [keys]
      prefix = "ctrl+a"
    '';
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
    signing = {
      key = signingKey;
      format = "openpgp";
      signByDefault = true;
    };
    settings = {
      user.name = "Daniel Xu";
      user.email = "hi@danielx.me";
      color.ui = true;
      github.user = "x0ba";
      push.default = "tracking";
      init.defaultBranch = "main";
      aliases = {
        cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";
        prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        root = "rev-parse --show-toplevel";
      };
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
      signing = {
        behavior = "own";
        backend = "gpg";
        key = signingKey;
      };
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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
  };

  programs.fish = {
    enable = true;
    shellAliases = shellAliases;
    functions.fish_greeting = "";
    interactiveShellInit = ''
      ${builtins.readFile ./config.fish}
      set -g SHELL ${pkgs.fish}/bin/fish
    '';

    plugins = with pkgs.fishPlugins; [
      {
        name = "fzf";
        src = fzf.src;
      }
      {
        name = "foreign-env";
        src = foreign-env.src;
      }
      {
        name = "bobthefish";
        src = bobthefish.src;
      }
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
