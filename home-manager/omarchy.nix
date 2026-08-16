{ ... }:
{
  # Standalone Home Manager on Omarchy (Arch + Hyprland).
  # Omarchy owns the desktop: Hyprland, waybar, walker, alacritty, themed nvim.
  # This only hooks HM into a non-NixOS user profile.
  targets.genericLinux.enable = true;
}
