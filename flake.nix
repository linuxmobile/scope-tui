{
  description = "A simple oscilloscope/vectorscope/spectroscope for your terminal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default-linux";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    fenix,
    systems,
    flake-utils,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;
    eachSystem = lib.genAttrs (import systems);
    pkgsFor = eachSystem (
      system: let
        systemPkgs = import nixpkgs {
          inherit system;
          overlays = [
            fenix.overlays.default
          ];
        };
      in
        systemPkgs
        // {
          myPackage = import ./nix/default.nix {
            inherit system;
            pkgs = systemPkgs;
            lockFile = ./Cargo.lock;
            fenix = fenix;
          };
        }
    );
  in {
    packages = eachSystem (system: {
      scope-tui = pkgsFor.${system}.myPackage;
    });

    checks = eachSystem (system: self.packages.${system});

    formatter = eachSystem (system: pkgsFor.${system}.alejandra);
  };
}
