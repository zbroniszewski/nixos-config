{ disk ? "/dev/vda", ... }:

{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = disk;

      content = {
        type = "gpt";

        partitions = {
          ESP = {
            priority = 1;
            label = "BOOT";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "defaults" "umask=0077" ];
            };
          };

          main = {
            size = "100%";
            label = "NixOS";

            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };

              content = {
                type = "btrfs";
                extraArgs = [ "--label" "NixOS" "-f" ];
                mountpoint = "/";

                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [ "subvol=root" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" "commit=120" ];
                  };

                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "subvol=home" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" "commit=120" "autodefrag" ];
                  };

                  "/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "subvol=log" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" "commit=120" "nodatacow" "nodatasum" ];
                  };

                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "subvol=nix" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" "commit=120" "nodatacow" "nodatasum" ];
                  };

                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "64G";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
