{
  description = "A basic flake for elixir development";

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

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      devshell,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ devshell.overlay ];
        };

        do-livebook-install = pkgs.writeShellScriptBin "do-livebook-install" ''
          mix local.hex --force
          mix local.rebar
          mix escript.install hex livebook --force
        '';
      in
      {
        formatter = pkgs.nixpkgs-fmt;

        packages = { };

        devShells.default =
          let
            elixir_ls = pkgs.elixir_ls.override { elixir = pkgs.elixir_1_14; };
          in
          pkgs.devshell.mkShell {
            imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];

            devshell.packages = [
              elixir_ls
              do-livebook-install
            ];
          };
      }
    );
}
