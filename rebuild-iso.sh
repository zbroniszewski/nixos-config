#!/usr/bin/env bash

set -e

# Build ISO
nix build \
  --show-trace \
  --extra-experimental-features "nix-command flakes" \
  .#nixosConfigurations.installer.config.system.build.isoImage

# Destroy previous VMs
for vm in $(virsh --connect qemu:///system list --all --name | grep '^nixos-iso-'); do
  virsh --connect qemu:///system destroy "$vm"
  virsh --connect qemu:///system undefine "$vm" \
    --remove-all-storage \
    --nvram
done

# Install new VM
new_vm_name="nixos-iso-$(date +"%Y-%m-%d-%H-%M-%S")"

virt-install \
  --name "$new_vm_name" \
  --memory 16384 \
  --vcpus 8 \
  --disk size=100 \
  --cdrom $(readlink -f $(find ./result/iso -type f)) \
  --os-variant nixos-unstable \
  --graphics spice \
  --boot uefi,menu=on \
  --connect qemu:///system \
  --noautoconsole

virt-manager \
  --connect qemu:///system \
  --show-domain-console \
  "$new_vm_name"
