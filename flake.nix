{
  description = "Busybox host + Installer ISO";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, home-manager, ... }:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.busybox = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./hardware-configuration.nix
        ./hosts/busybox
        ./hosts/busybox/disko.nix
        disko.nixosModules.disko
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.zach = import ./home.nix;
          };
        }
      ];
    };

    nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./hosts/installer
      ];
    };
  };
}
