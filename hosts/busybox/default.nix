{ config, pkgs, lib, ... }:

{
  networking.hostName = "busybox";

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;

  users.users.zach = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    git
    vim
    zsh
  ];

  programs.zsh.enable = true;

  # Required for flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 5;

  system.stateVersion = "24.11"; # adjust to your initial install version
}
