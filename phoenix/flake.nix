{
  description = "A flake for a Phoenix web application";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, utils, flake-compat }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        startdb = pkgs.writeShellApplication {
          name = "startdb";
          text = ''
            ${pkgs.postgresql}/bin/pg_ctl start -l "''${PGDATA:?}/server.log" -o "--unix_socket_directories=''${PGDATA:?}/../run/"
          '';
        };
        stopdb = pkgs.writeShellApplication {
          name = "stopdb";
          text = ''
            ${pkgs.postgresql}/bin/pg_ctl stop
          '';
        };
      in
      {
        packages = { };

        devShell = with pkgs; mkShell {
          buildInputs = [ erlang elixir postgresql ] ++ lib.optionals stdenv.isLinux [ libnotify inotify-tools ];
          nativeBuildInputs = [ (with nodePackages; pnpm) startdb stopdb nodejs-17_x elixir_ls ];
        };
      }
    );
}
