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

    echo "Selected $DISK"

    echo "Disko will wipe $DISK in 5 seconds. Press Ctrl+C to abort."
    sleep 5

    sudo nix run github:nix-community/disko -- \
      --mode destroy,format,mount \
      ${../busybox/disko.nix} \
      --arg disk "\"$DISK\"" \
      --yes-wipe-all-disks

    echo "Installing system..."

    sudo nixos-install \
      --no-root-password \
      --flake github:zbroniszewski/nixos-config#busybox

    echo "Done. Rebooting..."
    reboot
  '';
}
