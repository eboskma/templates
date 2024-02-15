{
  description = "Steel Bank Common Lisp project template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      devshell,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        devshell.flakeModule

        ./nix/sbcl.nix
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          formatter = pkgs.nixpkgs-fmt;

          devshells.default = {
            commands = [
              {
                name = "rsbcl";
                command = "${self'.packages.rsbcl}/bin/rsbcl";
                help = "Run sbcl with readline wrapper";
              }
            ];
          };
        };
    };
}
