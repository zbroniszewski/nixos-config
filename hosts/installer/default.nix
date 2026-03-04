{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  environment.systemPackages = with pkgs; [
    git
    gum
    disko
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Increase buffer size used for downloading flakes
  nix.settings.download-buffer-size = 524288000;

  systemd.services.autoInstall = {
    description = "Interactive NixOS installer";
    wantedBy = [ "multi-user.target" ];

    after = [ "network-online.target" "systemd-networkd-wait-online.service" ];
    before = [ "autovt@tty1.service" ];
    conflicts = [ "autovt@tty1.service" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "simple";

      StandardInput = "tty";
      StandardOutput = "tty";
      StandardError = "tty";

      TTYPath = "/dev/tty1";
      TTYReset = true;
      TTYVHangup = true;

      Environment = "PATH=${lib.makeBinPath [
        pkgs.bashInteractive
        pkgs.coreutils
        pkgs.gawk
        pkgs.git
        pkgs.gum
        pkgs.nix
        pkgs.nixos-install-tools
        pkgs.systemd
        pkgs.util-linux
      ]}";
    };

    script = ''
      set -Eeuxo pipefail
      trap 'echo "Installer failed at line $LINENO. Dropping to shell."; exec bash' ERR

      echo "Starting automated NixOS install..."

      echo "Select installation disk:"

      choice=$(
        lsblk -d -o NAME,SIZE --noheadings \
        | gum choose
      )

      [[ -n "$choice" ]] || { echo "Disk selection cancelled."; exec bash; }

      DISK="/dev/$(echo "$choice" | cut -d ' ' -f1)"

      echo "Selected disk: $DISK"

      git clone https://github.com/zbroniszewski/nixos-config /tmp/nixos-config \
        || { echo "Failed to clone config repo."; exec bash; }

      cd /tmp/nixos-config

      RAM_GiB=$(awk '/MemTotal/ { printf "%.0f\n", $2/1024/1024 }' /proc/meminfo)

      echo "Wiping, formatting and mounting $DISK..."

      nix run github:nix-community/disko -- \
        --mode zap_create_mount \
        ${../busybox/disko.nix} \
        --arg disk "\"$DISK\"" \
        --arg swapSize "\"$RAM_GiB\"" \
        --yes-wipe-all-disks

      nixos-generate-config --no-filesystems --root /mnt
      cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/busybox/

      echo "Installing NixOS to $DISK..."

      nixos-install \
        --no-root-password \
        --flake .#busybox

      echo "Done. Rebooting..."
      systemctl reboot
    '';
  };
}
