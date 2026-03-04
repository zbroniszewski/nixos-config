{ config, pkgs, ... }:

{
  home.username = "zach";
  home.homeDirectory = "/home/zach";

  programs.git.enable = true;
  programs.git.settings = {
    safe.directory = [ "/etc/nixos" ];
  };
  programs.zsh.enable = true;
  programs.ghostty.enable = true;

  home.packages = with pkgs; [
    htop
    ripgrep
  ];

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.systemd.enable = false;
  wayland.windowManager.hyprland.settings = {
    bind = [
      "SUPER, Return, exec, ghostty"
      "SUPER, W, killactive"
    ];
    debug.disable_logs = true;
  };

  # Hint Electron apps to use Wayland
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  home.stateVersion = "26.05";
}
