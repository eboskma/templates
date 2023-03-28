{
  description = "A flake for a Phoenix web application";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-parts, devshell, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; }
      {
        imports = [ devshell.flakeModule ];

        systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

        perSystem = { pkgs, ... }:
          let
            tailwindcss =
              let
                version = "3.3.0";
              in
              pkgs.stdenv.mkDerivation {
                pname = "tailwindcss";
                inherit version;

                src = builtins.fetchurl {
                  url = "https://github.com/tailwindlabs/tailwindcss/releases/download/v${version}/tailwindcss-linux-x64";
                  sha256 = "17mpkm83jwxzspimhgv9frlmqrzv7k0a384c2086gnvl4m3p7kqf";
                };

                dontUnpack = true;
                dontPatch = true;
                dontConfigure = true;
                dontBuild = true;
                dontFixup = true;

                installPhase = ''
                  install -Dm0755 $src $out/bin/tailwindcss
                '';
              };
          in
          {
            formatter = pkgs.nixpkgs-fmt;

            packages = { };

            devshells.default =
              {
                imports = [ "${inputs.devshell}/extra/services/postgres.nix" ];

                packages = with pkgs; [
                  erlang
                  libnotify
                  inotify-tools
                  nodejs
                  elixir_ls
                  gnumake
                  gcc
                ];

                services.postgres.initdbArgs = [ "--no-locale" "--encoding=UTF-8" ];

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
                    value = "${tailwindcss}/bin/tailwindcss";
                  }
                  {
                    name = "TAILWIND_VERSION";
                    value = tailwindcss.version;
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
