{ pkgs, ... }:
{
  home.homeDirectory = "/home/daniel";

  targets.genericLinux.enable = true;

  services.ssh-agent.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  my.herdr.autoExecOnSsh = true;
}
