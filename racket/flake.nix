{
  description = "A Racket development flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {

        formatter = pkgs.nixpkgs-fmt;

        devShells.default = with pkgs; mkShell { nativeBuildInputs = [ racket ]; };
      }
    );
}
