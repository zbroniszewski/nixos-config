{ config, pkgs, ... }:

{
  home.username = "zach";
  home.homeDirectory = "/home/zach";

  programs.git.enable = true;
  programs.zsh.enable = true;

  home.packages = with pkgs; [
    htop
    ripgrep
  ];

  home.stateVersion = "25.11";
}
