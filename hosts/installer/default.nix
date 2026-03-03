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

  services.spice-vdagentd.enable = true;
  systemd.services.spice-vdagentd.wantedBy = [ "default.target" ];

  programs.bash.loginShellInit = ''
    if [ -z "$AUTO_INSTALL_RAN" ]; then
      export AUTO_INSTALL_RAN=1

      clear
      echo "Starting automated installation..."

      DISK=$(${pkgs.util-linux}/bin/lsblk -d -o NAME,SIZE --noheadings \
        | ${pkgs.gum}/bin/gum choose \
        | awk '{print "/dev/"$1}')

      echo "Selected $DISK"

      TOKEN=$(${pkgs.gum}/bin/gum input --password --prompt "GitHub PAT (repo read access): ")

      FLAKE_URL=git+https://$TOKEN@github.com/zbroniszewski/nixos-config.git#busybox

      echo "Running disko..."
      nix run github:nix-community/disko -- \
        --mode destroy,format,mount \
        ${../busybox/disko.nix} \
        --arg disk "\"$DISK\"" \
        --yes-wipe-all-disks

      echo "Installing system..."
      nixos-install \
        --no-root-password \
        --flake "$FLAKE_URL"

      echo "Done. Rebooting..."
      reboot
    fi
  '';
}
