{
  description = "A Nix Flake for Omega RPG related stuff";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    # version through flake lock
    # using this in the original repo still seems tedious due to the submodule
    omegarpg-src = {
      url = "git+https://github.com/R-Rudolph/OmegaRPG.git?submodules=1";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, omegarpg-src, flake-utils }:
    {
      nixosModules.omegarpg = (import ./modules/nixos/omegarpg.nix) self;
    } // 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs {
          inherit system;
        });
      in rec {
        packages = rec {
          omegarpg = pkgs.callPackage (import ./pkgs/omegarpg) {
              omegarpgSrc = omegarpg-src;
              qt = pkgs.qt5;
          };
          omegarpg-server-with-config = pkgs.callPackage (import ./pkgs/omegarpg-server-with-config) {
            omegarpg = omegarpg;
          };
          default = omegarpg;
        };
        apps = rec {
          omegarpg = {
            type = "app";
            program = "${packages.omegarpg}/bin/OmegaRPG";
          };
          omegarpg-server-cli = {
            type = "app";
            program = "${packages.omegarpg}/bin/OmegaRPG-Server-CLI";
          };
          omegarpg-server-gui = {
            type = "app";
            program = "${packages.omegarpg}/bin/OmegaRPG-Server-GUI";
          };
          default = omegarpg;
        };
      }
    );
}