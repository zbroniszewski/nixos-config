{ config, pkgs, lib, ... }:

{
  networking.hostName = "busybox";
  # networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  # services.openssh.enable = true;

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.zsh.enable = true;

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
  boot.initrd.availableKernelModules = [
    # VM
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"

    # NVMe
    "nvme"

    # SATA
    "ahci"

    # USB
    "xhci_pci"
  ];

  system.stateVersion = "25.11";
}
