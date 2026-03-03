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

  environment.loginShellInit = ''
    set -Eeuo pipefail
    trap 'echo "Installer failed. Dropping to shell."; exec bash' ERR

    if [ -f /tmp/installer-ran ]; then
      return
    fi

    touch /tmp/installer-ran

    echo "Waiting for network..."
    until ip route | grep -q default; do
      sleep 1
    done

    echo "Network ready. Starting automated installation..."

    if ! DISK=$(${pkgs.util-linux}/bin/lsblk -d -o NAME,SIZE --noheadings \
        | ${pkgs.gum}/bin/gum choose \
        | awk '{print "/dev/"$1}'); then
      echo "Disk selection cancelled."
      exec bash
    fi

    RAM_GiB=$(awk '/MemTotal/ { printf "%.0f\n", $2/1024/1024 }' /proc/meminfo)

    echo "Wiping, formatting and mounting $DISK..."

    sudo nix run github:nix-community/disko -- \
      --mode zap_create_mount \
      ${../busybox/disko.nix} \
      --arg disk "\"$DISK\"" \
      --arg swapSize "\"$RAM_GiB\"" \
      --yes-wipe-all-disks

    echo "Installing NixOS to $DISK..."

    sudo nixos-install \
      --no-root-password \
      --write-efi-boot-entries \
      --flake github:zbroniszewski/nixos-config#busybox

    echo "Done. Rebooting..."
    reboot
  '';
}
