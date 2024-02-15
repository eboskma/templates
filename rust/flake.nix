{
  description = "A flake for a Rust application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-parts,
      rust-overlay,
      pre-commit-hooks,
      crane,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        pre-commit-hooks.flakeModule

        ./nix/hello-ferris.nix
      ];

      perSystem =
        {
          config,
          self',
          pkgs,
          system,
          ...
        }:
        {

          devShells.default = self'.devShells.hello-ferris;
        };
    };
}
