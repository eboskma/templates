{
  description = "A basic flake for meson projects";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, flake-compat }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nativeBuildInputs = with pkgs; [ meson ninja clang-tools gcc ];
      in
      {
        packages = { };

        devShell = with pkgs; mkShell {
          inherit nativeBuildInputs;
        };

      });
}
