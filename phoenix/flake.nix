{
  description = "A flake for a Phoenix web application";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, devshell, ... }@inputs:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        packages = { };

        devShells.default =
          pkgs.devshell.mkShell {
            imports = [
              (pkgs.devshell.importTOML ./devshell.toml)
            ];
          };
      });
}
