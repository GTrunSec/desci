{
  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    dream2nix.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    omnibusSrc.url = "github:tao3k/omnibus";
    omnibusSrc.flake = false;
  };

  outputs =
    inputs@{
      self,
      dream2nix,
      nixpkgs,
      flake-parts,
      ...
    }:
    let
      std = import ./nix/std;
      omnibus = import inputs.omnibusSrc;
      pops = {
        flakeModules = omnibus.pops.nixosProfiles.addLoadExtender {
          load = {
            src = ./nix/flake-parts;
            inputs = {
              inherit std dream2nixModules;
            };
          };
        };
        dream2nixModules = omnibus.pops.nixosProfiles.addLoadExtender {
          load = {
            src = ./nix/dream2nix;
            inputs = {
              inherit dream2nix;
            };
          };
        };
      };
      dream2nixModules = pops.dream2nixModules.exports.default;
      flakeModules = pops.flakeModules.exports.default;
    in
    flake-parts.lib.mkFlake { inherit inputs; } ({
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
        "aarch64-linux"
      ];
      flake = {
        inherit pops flakeModules dream2nixModules;
      };
      imports = [
        flakeModules.packages
      ];
    });
  nixConfig = {
    extra-substituters = [
      "https://tweag-topiary.cachix.org"
      "https://tweag-nickel.cachix.org"
      "https://organist.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "tweag-topiary.cachix.org-1:8TKqya43LAfj4qNHnljLpuBnxAY/YwEBfzo3kzXxNY0="
      "tweag-nickel.cachix.org-1:GIthuiK4LRgnW64ALYEoioVUQBWs0jexyoYVeLDBwRA="
      "organist.cachix.org-1:GB9gOx3rbGl7YEh6DwOscD1+E/Gc5ZCnzqwObNH2Faw="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };
}
