# Placeholder — replace with the output of nixos-generate-config.
{
  boot.loader.systemd-boot.enable = true;

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
