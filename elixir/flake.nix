{
  description = "A basic flake for elixir development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    next-ls = {
      url = "github:elixir-tools/next-ls";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      imports = [
        inputs.devshell.flakeModule
        inputs.pre-commit-hooks.flakeModule

        ./devshell.nix
      ];

      perSystem =
        {
          pkgs,
          system,
          lib,
          ...
        }:
        {

          formatter = pkgs.nixfmt-rfc-style;

          pre-commit = {
            settings = {
              hooks = {
                nil.enable = true;
                nixfmt.enable = true;
                deadnix.enable = true;
                mix-format.enable = true;
                # credo.enable = true;
                # dialyzer.enable = true;
              };
              tools = {
                nixfmt = lib.mkForce pkgs.nixfmt-rfc-style;
              };
            };
          };

          packages = { };
        };
    };
}
