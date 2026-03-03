{ config, pkgs, lib, ... }:

{
  networking.hostName = "busybox";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  services.openssh.enable = true;

  services.getty.autologinUser = "zach";

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
