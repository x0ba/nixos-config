# nix-config

Personal flake for a Mac (nix-darwin + home-manager) and a Linux box (home-manager only).

Use the [Determinate Nix installer](https://docs.determinate.systems/determinate-nix).
## Setup

**1. Install Determinate Nix.**

macOS: download [Determinate.pkg](https://install.determinate.systems/mac).

Linux:

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**2. Clone this repo.**

```sh
git clone git@github.com:x0ba/nixos-config.git ~/Code/p/nix-config
cd ~/Code/p/nix-config
```

**3. On macOS, install Homebrew** if it is not already there. nix-darwin drives casks and a few brews through it.

**4. Activate.** `direnv` puts `nh` on `PATH` in this repo.

```sh
# macOS
nh darwin switch

# Linux
nh home switch -c tp
```

First switch on a Mac may ask you to set the login shell and will write a `.backup` next to any files home-manager wants to own.

The Darwin hostname must match `networking.hostName` in `darwin/configuration.nix` (currently `Daniels-MacBook-Pro`). `nh` uses the machine hostname to pick the config.

## Day to day

| Command | What it does |
| --- | --- |
| `nh darwin switch` / `nh home switch` | Build and activate this machine |
| `nh darwin build` / `nh home build` | Build without activating |
| `nix flake update` | Bump `flake.lock` |
| `nix fmt` | Format Nix |
| `nix fmt -- --ci && nix flake check` | Format check + eval both hosts |

`direnv` loads the flake's dev shell (`nil`, `nixfmt-tree`, `nh`) when you `cd` into the repo. After the first switch, `nh` is also on your user profile (`NH_FLAKE` points at `~/Code/p/nix-config`).

## Architecture

```
flake.nix                   inputs, outputs, host wiring
darwin/configuration.nix    nix-darwin: users, Homebrew, fonts, shells, Touch ID
home-manager/home.nix       shared user env (packages, git, shells)
home-manager/darwin.nix     Darwin-only (Ghostty, brew shellenv)
home-manager/linux.nix      Linux-only (genericLinux, ssh-agent, herdr)
modules/home-manager/       optional HM features (herdr-on-SSH)
```

**One nixpkgs pin.** Unstable. home-manager and nix-darwin both follow it.

**Darwin** is one `darwinSystem` named `Daniels-MacBook-Pro`. home-manager is a nix-darwin module (`useGlobalPkgs`, `useUserPackages`), so one `nh darwin switch` applies system and user config. Homebrew `onActivation.cleanup = "uninstall"` makes the cask/brew lists authoritative.

**Linux** is a standalone home-manager config (`tp` / `daniel@tp`). `nix flake check` evaluates both hosts on either machine so shared `home.nix` and Darwin-module breaks show up before you switch.

**Feature modules** live under `modules/home-manager` and are imported by `home.nix`, not exported from the flake. `my.herdr.autoExecOnSsh` is on for Linux only.

Most CLI tools live in project flakes, so `home.packages` stays short. GUI apps on the Mac come from Homebrew casks. Fish plugins (bobthefish, fzf, foreign-env) come from `pkgs.fishPlugins`.
