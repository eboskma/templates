{
  description = "A flake for a Phoenix web application";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, devshell, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };
        tailwindcss =
          let
            version = "3.1.8";
          in
          pkgs.stdenv.mkDerivation {
            pname = "tailwindcss";
            inherit version;

            src = builtins.fetchurl {
              url = "https://github.com/tailwindlabs/tailwindcss/releases/download/v${version}/tailwindcss-linux-x64";
              sha256 = "0dzk9lm61s78lvcm5bhmi0qmfy5dssac1yrxysf5b99nayna0xzv";
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

        devShells.default =
          pkgs.devshell.mkShell {
            imports = [
              (pkgs.devshell.importTOML ./devshell.toml)
            ];

            env = [
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
          };
      });
}
