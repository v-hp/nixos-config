{
  description = "NixOS config and tools by vsevolodp";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkg-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # vim stuff
    fugitive = {
      url = "github:tpope/vim-fugitive";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      "vm-gnome-boxes" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.vsevolodp = import ./users/vsevolodp/home.nix;

	    home-manager.extraSpecialArgs = { inherit inputs; };
          }

          ./users/vsevolodp/nixos.nix
          ./machines/thinkpad-gnome-boxes.nix
        ];
      };
    };
  };
}
