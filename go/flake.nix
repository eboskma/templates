{
  description = "A flake for developing Go software";

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
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
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
          treefmt = {
            projectRootFile = "flake.lock";

            programs = {
              deadnix.enable = true;
              nixfmt.enable = true;
              statix.enable = true;

              gofumpt.enable = true;
            };
          };

          pre-commit = {
            settings.hooks = {
              deadnix.enable = true;
              nixfmt-rfc-style.enable = true;
              statix.enable = true;

              gofmt.enable = true;
              revive.enable = true;
            };
          };

          devShells.default =
            with pkgs;
            mkShell {
              packages = [
                go
                gopls
                gotools
                go-tools
              ];

              shellHook = ''
                ${config.pre-commit.installationScript}
              '';
            };
        };
    };
}
