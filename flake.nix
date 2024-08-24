{
  description = "A flake with Emacs as the default package for x86_64-linux";

  inputs = {
    systems.url = "github:nix-systems/x86_64-linux";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
    emacs-overlay.url = "github:nix-community/emacs-overlay";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    dotfiles = {
      url = "github:erik-sundin-git/dotfiles";
      flake = false;
    };
  };

  outputs = {
    self,
    flake-utils,
    dotfiles,
    emacs-overlay,
    nixpkgs,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        system = system;
        overlays = [emacs-overlay.overlays.emacs emacs-overlay.overlays.package];
      };
    in {

      # Set Emacs as the default package
      defaultPackage = pkgs.emacsWithPackagesFromUsePackage {
        config = "./config/init.el";
        package = pkgs.emacs-git;
      };


      # Set up a development shell with Emacs
      devShell = pkgs.mkShell {
        buildInputs = [pkgs.custom-emacs];
      };
    });
}
