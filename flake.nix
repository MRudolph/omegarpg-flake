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
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs {
          inherit system;
        });
      in rec {
        packages = rec {
          omegarpg = pkgs.callPackage (import ./omegarpg.nix) {
              omegarpgSrc = omegarpg-src;
              qt = pkgs.qt5;
          };
          default = omegarpg;
        };
        apps = rec {
          omegarpg = {
            type = "app";
            program = "${packages.omegarpg}/bin/OmegaRPG";
          };
          default = omegarpg;
        };
      }
    );
}
