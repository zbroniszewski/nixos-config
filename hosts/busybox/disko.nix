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

            content = {
              type = "luks";
              name = "cryptroot";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };

              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                mountpoint = "/";
                mountOptions = [ "compress=zstd" ];
              };
            };
          };
        };
      };
    };
  };
}
