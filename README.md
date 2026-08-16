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

**4. Activate.**

```sh
make switch
```

On Darwin this runs `darwin-rebuild switch` against `darwinConfigurations.<LocalHostName>`. On Linux it runs home-manager against `homeConfigurations.tp`. First switch on a Mac may ask you to set the login shell and will write a `.backup` next to any files home-manager wants to own.

The Darwin hostname must match `networking.hostName` in `darwin/configuration.nix` (currently `Daniels-MacBook-Pro`). `scutil --get LocalHostName` is what the Makefile uses.

## Day to day

| Command | What it does |
| --- | --- |
| `make switch` | Build and activate this machine |
| `make build` | Build without activating |
| `make update` | Bump `flake.lock` |
| `make fmt` | Format Nix |
| `make check` | Format check + `nix flake check` |

`direnv` loads the flake's dev shell (`nil`, `nixfmt-tree`) when you `cd` into the repo.

## Architecture

```
flake.nix                 inputs, outputs, host wiring
darwin/configuration.nix  nix-darwin: users, Homebrew, shells
home-manager/home.nix     shared user env (packages, git, shells)
home-manager/linux.nix    Linux-only (genericLinux, ssh-agent)
overlays/                 custom pkgs, pin overrides, pkgs.stablePkgs
pkgs/                     packages added via the additions overlay
modules/                  exported HM/darwin modules (thin today)
```

**Two nixpkgs pins.** Unstable is the default. 25.11 is `pkgs.stablePkgs` via the `stable-packages` overlay. home-manager and nix-darwin both follow unstable.

**Darwin** is one `darwinSystem` named `Daniels-MacBook-Pro`. home-manager is a nix-darwin module (`useGlobalPkgs`, `useUserPackages`), so one `make switch` applies system and user config.

**Linux** is a standalone home-manager config (`tp` / `daniel@tp`). No NixOS host is wired in `flake.nix` yet. `nixos/` is a leftover template.

**Overlays** are applied on both sides:

- `additions` imports `./pkgs`
- `modifications` is empty, ready for overrides
- `stable-packages` exposes `pkgs.stablePkgs`

Most CLI tools live in project flakes, so `home.packages` stays short. GUI apps on the Mac come from Homebrew casks.
