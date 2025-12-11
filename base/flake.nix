{
  description = "An empty base flake with a devShell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
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
              nixfmt.enable = true;
              deadnix.enable = true;
              statix.enable = true;
            };
          };

          pre-commit = {
            settings = {
              hooks = {
                nixfmt.enable = true;
                deadnix.enable = true;
                static.enable = true;
              };
            };
          };

          devShells.default =
            with pkgs;
            mkShell {
              packages = [ ];

              inherit (config.pre-commit) shellHook;
            };
        };
    };
}
