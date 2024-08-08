{
  description = "main";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations = {
      laud = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./system/laud.nix
          ./net.nix
          ./user.nix
          ./audio.nix
          ./locale.nix
          ./packages.nix
        ];
      };

      latitude = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./system/latitude.nix
          ./net.nix
          ./user.nix
          ./audio.nix
          ./locale.nix
          ./packages.nix
        ];
      };
    };

    homeConfigurations = {
      maun = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
  };
}
