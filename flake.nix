{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, nixvim, flake-utils, home-manager, ... }:
    let
      system = "x86_64-linux";
      overlays = import ./overlays { inherit inputs; };
      pkgs = import nixpkgs {
	inherit system;
        config.allowUnfree = true;
	overlays = with overlays; [
          local-packages
	  modifications
	  unstable-packages
	];
      };
    in rec {
      nixosConfigurations.nkbox = nixpkgs.lib.nixosSystem {
	inherit system pkgs;
        modules = with nixos-hardware.nixosModules; [
	  common-pc-ssd
          common-gpu-nvidia-nonprime
          ./hardware/nkbox.nix
          ./hosts/common.nix
          ./hosts/nkbox.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              users.nikoof = import ./users/nikoof;
            };
          }
	  nixvim.nixosModules.nixvim {
            programs.nixvim = {
	      colorschemes.nord.enable = true;
	    };
	  }
        ];
      };

      nixosConfigurations.nkideapad = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = with nixos-hardware.nixosModules; [
	  common-pc-laptop
          common-pc-laptop-ssd
	  common-gpu-nvidia
	  ./hardware/nkideapad.nix
	  ./hosts/common.nix
          ./hosts/nkideapad.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              users.nikoof = import ./users/nikoof;
            };
          }
        ];
      };

      nixosConfigurations.nkideapad-old = nixpkgs.lib.nixosSystem {
	inherit system pkgs;
        modules = [
          nixos-hardware.nixosModules.common-pc-laptop-hdd
	  nixos-hardware.nixosModules.common-gpu-intel
	  ./hardware/nkideapad-old.nix
          ./hosts/nkideapad-old.nix
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              users.nikoof = import ./users/nikoof;
            };
          }
        ];
      };
    };
}
