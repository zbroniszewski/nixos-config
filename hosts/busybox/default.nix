{ config, pkgs, lib, ... }:

{
  # Suppress boot logs
  boot.kernelParams = lib.mkAfter [ "quiet" "udev.log_level=0" ];
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  networking.hostName = "busybox";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  # services.openssh.enable = true;

  programs.uwsm.enable = true;
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.zsh.enable = true;

  services.greetd.enable = true;
  services.greetd.settings = {
    default_session = {
      command = "start-hyprland";
      user = "zach";
    };
  };

  # services.getty.autologinUser = "zach";

  users.users.zach = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$RjvOGDRBEf36J8suQPtrV.$rKEABL7XZolwtS6l2ddMMRZKCGMkezH2yp0Tg41O8p8";
    createHome = true;
    home = "/home/zach";
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    git
    vim
    zsh
  ];

  # Required for flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "26.05";
}
