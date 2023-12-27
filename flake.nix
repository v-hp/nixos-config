{
  description = "NixOS config and tools by vsevolodp";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkg-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      "vm-mbr" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./users/vsevolodp/home.nix
          ./machines/vm-mbr.nix
        ];
      };
    };
  };
}
