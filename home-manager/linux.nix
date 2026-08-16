{ ... }:
{
  home.homeDirectory = "/home/daniel";

  targets.genericLinux.enable = true;

  services.ssh-agent.enable = true;

  my.herdr.autoExecOnSsh = true;
}
