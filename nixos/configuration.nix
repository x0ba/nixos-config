{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
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
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      # Disable the global flake registry.
      flake-registry = "";
    };
    channel.enable = false;
  };

  # FIXME: add the rest of your current configuration

  # TODO: set your hostname
  networking.hostName = "your-hostname";

  users.users = {
    # FIXME: replace with your username
    your-username = {
      # Skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Change this with passwd after the first boot.
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        # TODO: add SSH public keys if you plan to log in over SSH
      ];
      extraGroups = [ "wheel" ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
