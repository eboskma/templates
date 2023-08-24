{
  description = "A basic flake for elixir development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-parts, devshell, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      imports = [ ./devshell.nix ];

      perSystem = { pkgs, system, ... }: {

        _module.args.pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlays.default ];
        };

        formatter = pkgs.nixpkgs-fmt;

        packages = { };
      };
    };
}
