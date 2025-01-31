{
  description = "A flake to build Gleam applications";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        inputs.git-hooks.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, config, ... }:
        {
          pre-commit = {
            settings = {
              hooks = {
                nixfmt-rfc-style.enable = true;
                deadnix.enable = true;
                taplo.enable = true;
              };
            };
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              deadnix.enable = true;
              gleam.enable = true;
              taplo.enable = true;
            };
          };

          devShells.default =
            with pkgs;
            mkShell {
              packages = [
                gleam
                erlang_27
                rebar3
                taplo
              ];

              shellHook = ''
                ${config.pre-commit.installationScript}
              '';
            };
        };
    };
}
