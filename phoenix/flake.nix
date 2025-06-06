{
  description = "A flake for a Phoenix web application";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      imports = [
        inputs.devshell.flakeModule
        inputs.git-hooks.flakeModule
        inputs.treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { pkgs, ... }:
        {
          formatter = pkgs.nixpkgs-fmt;

          pre-commit = {
            settings = {
              hooks = {
                nil.enable = true;
                nixfmt-rfc-style.enable = true;
                deadnix.enable = true;
                mix-format.enable = true;
                # credo.enable = true;
                # dialyzer.enable = true;
              };
            };
          };

          treefmt = {
            rootProjectFile = "flake.lock";

            programs = {
              nixfmt.enable = true;
              deadnix.enable = true;
              mix-format.enable = true;
            };
          };

          packages = { };

          devshells.default = {
            imports = [ "${inputs.devshell}/extra/services/postgres.nix" ];

            packages = with pkgs; [
              elixir
              erlang
              next-ls
              libnotify
              inotify-tools
              nodejs
              gnumake
              gcc
            ];

            services.postgres.initdbArgs = [
              "--no-locale"
              "--encoding=UTF-8"
            ];

            env = [
              {
                name = "HEX_HOME";
                eval = "$PWD/.nix/hex";
              }
              {
                name = "MIX_HOME";
                eval = "$PWD/.nix/mix";
              }
              {
                name = "PATH";
                prefix = "$MIX_HOME/escripts";
              }
              {
                name = "ERL_AFLAGS";
                value = "-kernel shell_history enabled";
              }
              {
                name = "ESBUILD_PATH";
                value = "${pkgs.esbuild}/bin/esbuild";
              }
              {
                name = "ESBUILD_VERSION";
                value = pkgs.esbuild.version;
              }
              {
                name = "TAILWIND_PATH";
                value = "${pkgs.tailwindcss}/bin/tailwindcss";
              }
              {
                name = "TAILWIND_VERSION";
                value = pkgs.tailwindcss.version;
              }
            ];

            commands = [
              {
                name = "mix";
                package = pkgs.elixir;
                help = "mix";
              }
            ];
          };
        };
    };
}
